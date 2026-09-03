# 发布指南

## 概述

Everything-CJ 使用 cjpm 构建系统进行发布。本文档说明如何构建和发布二进制文件。

## 前置要求

### 安装 Cangjie SDK

```bash
# 下载 Cangjie SDK
# 访问 https://cangjie-lang.cn/download

# 安装 SDK
# 按照官方文档安装
```

### 安装 cjpm

```bash
# 安装 cjpm
cjc install cjpm

# 验证安装
cjpm --version
```

## 构建

### 开发构建

```bash
# 构建调试版本
cjpm build

# 运行测试
cjpm test

# 格式化代码
cjpm fmt .
```

### 发布构建

```bash
# 构建发布版本
cjpm build --release

# 指定目标平台
cjpm build --release --target x86_64-pc-windows-msvc
```

## 发布流程

### 使用发布脚本

```bash
# 赋予执行权限
chmod +x scripts/release.sh

# 执行发布
./scripts/release.sh 1.0.0 x86_64-pc-windows-msvc
```

### 手动发布

```bash
# 1. 构建
cjpm build --release

# 2. 创建发布目录
mkdir -p dist/everything_cli-1.0.0

# 3. 复制二进制文件
target/x86_64-pc-windows-msvc/release/Everything-CJ.exe dist/everything_cli-1.0.0/
target/x86_64-pc-windows-msvc/release/ES.exe dist/everything_cli-1.0.0/

# 4. 复制文档
cp README.md CHANGELOG.md LICENSE dist/everything_cli-1.0.0/

# 5. 创建压缩包
cd dist
tar -czf everything_cli-1.0.0.tar.gz everything_cli-1.0.0
zip -r everything_cli-1.0.0.zip everything_cli-1.0.0
```

## 发布检查清单

### 代码检查

- [ ] 所有测试通过
- [ ] 代码格式化完成
- [ ] 无编译警告
- [ ] 文档完整

### 构建检查

- [ ] 开发构建成功
- [ ] 发布构建成功
- [ ] 所有目标平台构建成功

### 功能检查

- [ ] 索引构建正常
- [ ] 搜索功能正常
- [ ] CLI 工具正常
- [ ] HTTP API 正常

### 文档检查

- [ ] README.md 更新
- [ ] CHANGELOG.md 更新
- [ ] 版本号正确

## 版本管理

### 版本号格式

使用语义化版本 (SemVer):

```
主版本号.次版本号.修订号
- 主版本号: 不兼容的 API 变更
- 次版本号: 向后兼容的功能新增
- 修订号: 向后兼容的问题修复
```

### 版本标签

```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签
git push origin v1.0.0
```

## 发布平台

### GitHub Releases

```bash
# 使用 gh 工具发布
gh release create v1.0.0 \
  dist/everything_cli-1.0.0.tar.gz \
  dist/everything_cli-1.0.0.zip \
  -t "Everything-CJ v1.0.0" \
  -n "Release notes..."
```

### GitCode Releases

```bash
# 使用 gitcode CLI 发布
gitcode release create v1.0.0 \
  dist/everything_cli-1.0.0.tar.gz \
  dist/everything_cli-1.0.0.zip
```

## 持续集成

### GitHub Actions 配置

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Cangjie
        uses: cangjie/setup-cj@v1
        with:
          version: '1.0'
      
      - name: Build
        run: cjpm build --release
      
      - name: Upload Release
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*
```

## 回滚

### 版本回滚

```bash
# 回滚到上一个版本
git revert v1.0.0
git push origin master
```

### 二进制回滚

```bash
# 删除当前版本
git tag -d v1.0.0

# 恢复上一个版本
git checkout v0.1.0
```

## 常见问题

### 构建失败

```bash
# 清理构建缓存
cjpm clean

# 重新构建
cjpm build --release
```

### 测试失败

```bash
# 运行特定测试
cjpm test --filter 'search'

# 详细输出
cjpm test --verbose
```

### 发布失败

```bash
# 检查网络连接
ping gitcode.com

# 检查认证
gitcode auth status

# 重新认证
gitcode auth login
```
