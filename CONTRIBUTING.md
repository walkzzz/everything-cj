# 贡献指南

感谢你考虑为 Everything-CJ 做出贡献！

## 📋 目录

- [行为准则](./CODE_OF_CONDUCT.md)
- [如何贡献](#如何贡献)
- [开发环境搭建](#开发环境搭建)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [代码审查流程](#代码审查流程)

## 🤔 如何贡献

### 报告 Bug

1. 在 [Issues](https://gitcode.com/hw_aishell_projects/everything_cli/issues) 中搜索是否已有相同问题
2. 如果没有，创建新的 Issue，使用 `bug` 标签
3. 提供以下信息：
   - 操作系统版本
   - Cangjie 版本
   - 复现步骤
   - 预期行为 vs 实际行为

### 提出新功能

1. 在 [Issues](https://gitcode.com/hw_aishell_projects/everything_cli/issues) 中创建新 Issue，使用 `feature` 标签
2. 描述功能用途、使用场景、实现思路
3. 等待维护者讨论和确认

### 提交代码

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m "feat: add your feature"`
4. 推送分支：`git push origin feature/your-feature`
5. 创建 Pull Request

## 🛠️ 开发环境搭建

### 前置要求

- Cangjie 1.0+
- cjpm 1.0+
- Git

### 构建步骤

```bash
# 克隆仓库
git clone https://gitcode.com/hw_aishell_projects/everything_cli.git

# 进入项目目录
cd everything_cli

# 安装依赖
cjpm install

# 构建
cjpm build --release

# 运行测试
cjpm test
```

## 💻 代码规范

### Cangjie 代码规范

- 使用 `cjfmt` 格式化代码：`cjfmt format .`
- 使用 `cjlint` 检查代码：`cjlint check .`
- 遵循 Cangjie 官方编码规范

### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 变量 | camelCase | `fileName`, `fileSize` |
| 函数 | camelCase | `searchFiles`, `buildIndex` |
| 类 | PascalCase | `IndexEngine`, `QueryParser` |
| 常量 | UPPER_CASE | `MAX_RESULTS`, `DEFAULT_PORT` |
| 枚举 | PascalCase | `FileChange`, `SortOrder` |

### 注释规范

- 公共 API 必须有文档注释
- 复杂逻辑必须有行内注释
- 使用中文注释（除非是技术术语）

```cangjie
/// 搜索文件
/// 
/// # 参数
/// - query: 搜索关键词
/// - options: 搜索选项
/// 
/// # 返回
/// 搜索结果列表
func searchFiles(query: String, options: SearchOptions): SearchResult[] {
    // 实现逻辑
}
```

## 📝 提交规范

### Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加 HTTP API` |
| `fix` | Bug 修复 | `fix: 修复索引构建错误` |
| `docs` | 文档更新 | `docs: 更新 README` |
| `style` | 代码格式 | `style: 格式化代码` |
| `refactor` | 代码重构 | `refactor: 重构搜索模块` |
| `test` | 测试相关 | `test: 添加单元测试` |
| `chore` | 构建/工具 | `chore: 更新依赖` |

### Scope 范围

- `core` - 核心引擎
- `search` - 搜索模块
- `storage` - 存储模块
- `ui` - 用户界面
- `cli` - 命令行工具
- `docs` - 文档

### 示例

```
feat(core): 添加 MFT 读取器

- 实现 MFT 文件读取
- 支持增量读取
- 添加单元测试

Closes #123
```

## 🔍 代码审查流程

### Pull Request 要求

1. 关联相关 Issue
2. 通过所有测试
3. 代码覆盖率 > 80%
4. 通过 `cjfmt` 格式化
5. 通过 `cjlint` 检查

### 审查标准

- 代码逻辑正确
- 遵循代码规范
- 测试覆盖充分
- 文档更新完整
- 无安全问题

## 📚 资源

- [Cangjie 官方文档](https://cangjie-lang.cn/docs)
- [Cangjie 标准库 API](https://cangjie-lang.cn/api)
- [Cangjie 中心仓](https://pkg.cangjie-lang.cn)

---

**感谢你的贡献！** 🎉
