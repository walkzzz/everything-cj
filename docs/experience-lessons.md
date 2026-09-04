# 仓颉项目发布工程经验教训

> 记录时间: 2026-09-04  
> 项目: Everything-CJ (github.com/walkzzz/everything-cj)  
> SDK: Cangjie 1.1.3 (STS, cjnative)  
> 目标: 多平台二进制构建 + GitHub Release 自动化

---

## 一、cjpm 包管理陷阱

### 1.1 子目录包名必须遵循 `parent.child` 规范

**现象:** `cjpm run` 报错：
```
Error: the package name in src/core is wrong, the right name should be 'everything_cj.core'
```

**原因:** `src/core/` 子目录中的 `.cj` 文件缺少 `package` 声明（第一行是注释而非 `package everything_cj.core`）。cjpm 扫描 `src/` 下所有子目录，发现没有正确包名的目录就报错。

**解决:** 两种方案：
- **方案 A（推荐）:** 删除不需要的骨架子目录，保持单文件 `src/main.cj`
- **方案 B:** 给每个子目录添加 `cjpm.toml`，并在每个 `.cj` 文件第一行声明 `package everything_cj.core` 等

**教训:** 不要在 `src/` 下留没有 `package` 声明的 `.cj` 文件。cjpm 会扫描所有子目录。

### 1.2 `cjpm run` 传参需要 `--`

```bash
cjpm run -- ext:md          # 正确：传递参数给程序
cjpm run ext:md             # 错误：ext:md 被 cjpm 消费
```

---

## 二、Cangjie 标准库 API 摸索方法

### 2.1 从 .cjo 文件提取 API 签名

SDK 的 `.cjo` 文件（编译后的模块声明）可以用 `strings` 命令提取 API：

```bash
strings $CANGJIE_HOME/modules/linux_aarch64_cjnative/std/std.fs.cjo | grep "Directory\|Path\|FileInfo" | sort -u
```

**关键发现:**

| 模块 | 正确 API | 错误尝试 |
|------|---------|---------|
| `std.fs` | `Directory.walk(path, callback)` | `listDir()` ❌ |
| `std.fs` | `info.isDirectory()` 方法调用 | `info.isDirectory` 属性 ❌ |
| `std.fs` | `info.path.toString()` | `info.path` 直接打印 ❌ |
| `std.core` | `s.toAsciiLower()` | `s.toLowerAscii()` ❌ |
| `std.core` | `s[0..n]` Range 索引 | `s.substring(0, n)` ❌ |
| `std.core` | `s.split("*")` 返回 Array | — |
| `std.core` | `s.indexOf("*")` 返回 `Option<Int64>` | — |
| `std.convert` | `Int64.parse(s)` 需要 `import std.convert` | 直接用 `Int64.parse` ❌ |
| `std.collection` | `ArrayList<T>()` + `.add()` | `Array<T>([])` ❌ |
| `std.env` | `getCommandLine()` 返回 `Array<String>` | `args()` ❌ |

### 2.2 Array vs ArrayList

```cangjie
// Array — 固定大小，创建时必须指定大小和初始化函数
let arr = Array<String>(10, { _ => "" })

// ArrayList — 动态大小，有 add() 方法
let list = ArrayList<String>()
list.add("hello")
```

**教训:** 需要动态添加元素时用 `ArrayList`，不是 `Array`。

### 2.3 Lambda 不能捕获可变变量

```cangjie
// ❌ 错误：lambda 捕获了可变变量 count
var count = 0
Directory.walk(".", { info =>
    count++    // error: lambda capturing mutable variables
    true
})

// ✅ 正确：用类包装可变状态
class Counter {
    var value: Int64
    init() { value = 0 }
    func inc(): Unit { value++ }
}
let counter = Counter()
Directory.walk(".", { info =>
    counter.inc()    // OK：捕获的是不可变的 counter 引用
    true
})
```

**教训:** Cangjie 的 lambda 不能捕获 `var`，只能捕获 `let`。需要可变状态时用类实例包装。

### 2.4 Directory.walk 回调签名

```cangjie
Directory.walk(path: String, callback: (FileInfo) -> Bool)
// 回调返回 true → 继续遍历
// 回调返回 false → 停止遍历
```

返回值是 `Bool` 不是 `Unit`，忘记写返回值会报类型错误。

---

## 三、Cangjie SDK 下载

### 3.1 cangjie-lang.cn 是 JS 渲染页面

直接 `curl` 下载页只返回 1.8K HTML（JS 渲染前）。SDK 下载 URL 在 version.js 中：

```bash
curl -s "https://csdnimg.cn/release/devpress-cangjie/public/js/chunk/organization/download/version.8e688f93.js" -o /tmp/version.js
# 用正则提取 nsId, fileName, objectKey
```

### 3.2 已知 SDK URL (1.1.3)

| SDK | objectKey | 大小 |
|-----|-----------|------|
| linux-x64 | `6a19349d21f5a8178d6fd22b` | ~403 MB |
| linux-aarch64 | `6a19350321f5a8178d6fd22c` | ~378 MB |
| mac-aarch64 | `6a19312721f5a8178d6fd225` | ~245 MB |

URL 模式: `https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName={file}&objectKey={key}`

**教训:** 这些 URL 可能随版本更新而变化，需要重新解析 version.js。

---

## 四、跨平台构建

### 4.1 SDK 架构必须匹配 Runner 架构

| Runner | 架构 | 可用 SDK | 交叉编译目标 |
|--------|------|---------|-------------|
| ubuntu-22.04 | x86_64 | linux-x64 ✅ | Windows x64 ✅ |
| ubuntu-22.04 | x86_64 | linux-aarch64 ❌ (Exec format error) | — |
| macos-14 | ARM64 | mac-aarch64 ✅ | ❌ 无 x86_64 模块 |

**关键:** macOS x86_64 不支持交叉编译，因为 Cangjie SDK 没有 `darwin_x86_64_cjnative` 模块。

### 4.2 macOS 需要 SDKROOT

```bash
# 不设置 → undefined symbol: _memcpy
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
# 编译时还需要传递链接器路径
cjc src/main.cj -B "$SDKROOT/usr/lib" -B "$SDKROOT/usr/lib/system" -s -o binary
```

### 4.3 Windows 交叉编译

```bash
cjc src/main.cj --target x86_64-pc-windows-gnu -s -o app.exe
# 产出 PE32+ executable x86-64
```

SDK 中包含 `windows_x86_64_cjnative` 运行时模块，交叉编译可行。

### 4.4 环境变量配置

```bash
export CANGJIE_HOME="$(pwd)/cangjie"
export PATH="$CANGJIE_HOME/bin:$CANGJIE_HOME/tools/bin:$PATH"

# Linux
export LD_LIBRARY_PATH="$CANGJIE_HOME/runtime/lib/$LIB_PATH:$CANGJIE_HOME/lib/$LIB_PATH"

# macOS
export DYLD_LIBRARY_PATH="$CANGJIE_HOME/runtime/lib/darwin_aarch64_cjnative:$CANGJIE_HOME/lib/darwin_aarch64_cjnative"
```

**教训:** 不设 `LD_LIBRARY_PATH` → `libcangjie-runtime.so: cannot open shared object file`。

---

## 五、产物打包格式

### 5.1 各平台推荐格式

| 平台 | 格式 | 创建方法 | 用户体验 |
|------|------|---------|---------|
| Linux | `.tar.gz` | `tar -czf` | 解压后运行 |
| macOS | `.dmg` | `hdiutil create` | 双击拖拽安装 |
| Windows | `.exe` | 直接编译产物 | 双击运行 |

### 5.2 macOS DMG 创建

```bash
mkdir -p dmg_content
cp binary dmg_content/
ln -s /Applications dmg_content/Applications    # 拖拽安装
hdiutil create -volname "App" -srcfolder dmg_content -ov -format UDZO app.dmg
```

**教训:** DMG 比 tar.gz 大约 2 倍（包含文件系统元数据），但用户体验好得多。

---

## 六、GitHub Actions CI/CD

### 6.1 YAML `"on"` 必须加引号

```yaml
"on":          # ✅ 正确
  push:
    tags: ['v*']

on:            # ❌ YAML 1.1 将 on 解析为布尔值 true
```

### 6.2 Release 权限

```yaml
permissions:
  contents: write    # 必需，否则创建 Release 返回 403
```

### 6.3 默认分支必须匹配

GitHub 新仓库默认分支是 `main`。如果推送的是 `master`，workflow 不会触发。

**解决:** 用 GitHub API 修改默认分支：
```bash
curl -X PATCH -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/user/repo \
  -d '{"default_branch": "master"}'
```

### 6.4 重新触发 Release

```bash
# 删除远程标签再重新推送
git push github :refs/tags/v1.0.0
git tag -d v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push github v1.0.0
```

### 6.5 glob 模式注意

```yaml
files: |
  artifacts/**/app-*.tar.gz    # ✅ 注意双星后要有斜杠
  artifacts**/app-*.exe         # ❌ 少了斜杠，匹配失败
```

### 6.6 构建矩阵 `fail-fast: false`

```yaml
strategy:
  fail-fast: false    # 一个平台失败不影响其他平台继续构建
```

---

## 七、SSH 与认证

### 7.1 SSH key 权限

```bash
chmod 600 ~/.ssh/id_ed25519    # 私钥权限不能太开放
```

**现象:** `Permissions 0750 for key are too open` → push 失败。

### 7.2 GitHub PAT 验证

```bash
curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | python3 -c "import json,sys; print(json.load(sys.stdin)['login'])"
```

---

## 八、专家技能管理

### 8.1 新增专家流程

1. 创建 `skills/<skill-name>/SKILL.md`（主技能入口）
2. 创建 `skills/<skill-name>/references/`（参考文档）
3. 更新 `skills/cangjie-router/SKILL.md`（添加路由类别）
4. 更新主文档 `仓颉开发专家天团.md`（添加专家档案）
5. 更新 `README.md`（添加技能列表条目）

### 8.2 SKILL.md 结构

```yaml
---
name: skill-name
description: >
  触发描述。当用户需要...时使用。
  涵盖...
author: cangjie-expert-team
version: 1.0.0
---

# 技能标题

## 触发场景
## 核心能力
## 默认工作流
## 常见问题与解决方案
## 文件结构
```

---

## 九、磁盘空间管理

**现象:** `git commit` 报 `No space left on device`，但 `df -h` 显示有 159G 可用。

**可能原因:** overlay 文件系统限制、git 临时目录满了、inode 耗尽。

**排查:** `df -h /`、`df -i /`、`du -sh .git/`

**解决:** `git gc --prune=now --aggressive`，清理 `target/`、SDK 临时文件等。

---

## 十、经验总结一句话

| # | 教训 |
|---|------|
| 1 | cjpm 扫描 src/ 下所有子目录，不要留没有 package 声明的 .cj 文件 |
| 2 | Cangjie String API: `toAsciiLower()` 不是 `toLowerAscii()`，用 `s[0..n]` 不是 `substring()` |
| 3 | Lambda 不能捕获 var，用类实例包装可变状态 |
| 4 | `Directory.walk` 回调返回 `Bool`（true 继续），不是 `Unit` |
| 5 | `info.isDirectory()` 是方法不是属性，要加括号 |
| 6 | `Array<T>(size, initFunc)` 不是 `Array<T>([])`，动态用 `ArrayList` |
| 7 | `Int64.parse()` 需要 `import std.convert` |
| 8 | SDK 架构必须匹配 Runner 架构，macOS 无 x86_64 交叉编译 |
| 9 | macOS 编译必须设 `SDKROOT`，否则链接器找不到系统符号 |
| 10 | YAML `"on"` 必须加引号，`permissions: contents: write` 必需 |
| 11 | GitHub 默认分支不匹配则 workflow 不触发 |
| 12 | SSH 私钥权限必须 600 |
| 13 | cangjie-lang.cn 是 JS 渲染页，SDK URL 在 version.js 中 |
| 14 | 从 .cjo 文件用 `strings` 提取 API 签名是最可靠的探索方法 |
| 15 | 重新触发 Release: 删除远程标签 → 重新创建 → 重新推送 |
