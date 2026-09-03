---
name: everything-cj
description: >
  Everything-CJ 仓颉版搜索工具。当用户需要开发、使用或维护 Everything-CJ 项目时使用。
  涵盖核心引擎、搜索模块、存储模块、CLI 工具、HTTP API。
  关键词: "Everything"、"搜索"、"文件搜索"、"MFT"、"索引"、"es.exe"、"everything_cli"。
author: cangjie-expert-team
---

# Everything-CJ

用于快速、可靠地开发和使用 Everything-CJ 仓颉版搜索工具。

## 默认工作流

### 1. 明确目标和约束
- 确认预期行为、非目标、兼容性约束。
- Everything-CJ 仅搜索文件名，不搜索文件内容。
- 支持 Windows 10/11，NTFS/FAT32/exFAT。

### 2. 定位模块边界
- 找到 `src/` 目录结构。
- 确定核心引擎、搜索模块、存储模块。

### 3. 编码前发现 API
- 优先使用 `cjpm ide doc` 查询现有 API。
- 使用 `cjpm ide outline` 进行语义导航。

### 4. 紧密循环验证
- 编辑后运行 `cjpm check`。
- 运行 `cjpm test` 验证功能。

### 5. 交付前完成
- 运行 `cjpm fmt`。
- 运行 `cjpm info` 验证 API 变更。

## 快速任务手册

### Bug 修复 (No API Change Intended)

1. 复现或识别失败行为。
2. 定位符号：`cjpm ide outline`。
3. 实现最小修复。
4. 验证：
   - `cjpm check`
   - `cjpm test --filter 'search'`
   - `cjpm fmt`
   - `cjpm info`

### 新特性或公共 API

1. 发现现有惯用法：`cjpm ide doc`。
2. 在带有 `///|` 分隔符的内聚文件中添加实现。
3. 添加黑盒测试和文档字符串示例。
4. 验证：
   - `cjpm check`
   - `cjpm test`
   - `cjpm fmt`
   - `cjpm info`

### 添加新搜索过滤器

1. 在 `search/query_parser.cj` 中添加解析逻辑。
2. 在 `storage/index_db.cj` 中添加查询逻辑。
3. 添加测试用例。
4. 验证：`cjpm test --filter 'query'`。

## 项目布局

```
everything_cli/
├── src/
│   ├── main.cj                  # 入口
│   ├── core/
│   │   ├── mft_reader.cj        # MFT 读取器
│   │   ├── index_engine.cj      # 索引引擎
│   │   └── file_monitor.cj      # 文件监控
│   ├── search/
│   │   ├── query_parser.cj      # 查询解析器
│   │   └── index_query.cj       # 索引查询
│   ├── storage/
│   │   └── index_db.cj          # 索引数据库
│   ├── network/
│   │   ├── http_server.cj       # HTTP 服务器
│   │   └── api.cj               # API 接口
│   ├── ui/
│   │   ├── main_window.cj       # 主窗口
│   │   ├── search_bar.cj        # 搜索栏
│   │   └── result_list.cj       # 结果列表
│   └── cli/
│       ├── es.cj                # ES.exe 命令行
│       └── main.cj              # CLI 入口
├── tests/
│   ├── core/
│   ├── search/
│   └── storage/
├── docs/
│   ├── usage.md
│   ├── search-syntax.md
│   ├── api.md
│   ├── configuration.md
│   └── faq.md
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
└── config.toml
```

## 核心模块

### MFT 读取器 (core/mft_reader.cj)

```cangjie
interface MFTReader {
    open(drive: Drive): Result<MFTHandle, MFTError>
    readAll(handle: MFTHandle): Result<MFTRecord[], MFTError>
    parseRecord(data: Byte[]): MFTRecord
}
```

### 查询解析器 (search/query_parser.cj)

```cangjie
interface QueryParser {
    parse(input: String): QueryPlan
    validate(input: String): ValidationResult
}
```

### 索引数据库 (storage/index_db.cj)

```cangjie
interface IndexDB {
    open(path: String): Result<Unit, DBError>
    insertFile(file: FileEntry): Result<Unit, DBError>
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError>
}
```

## CLI 使用

```bash
# 简单搜索
es.exe report

# 后缀过滤
es.exe ext:pdf report

# 大小过滤
es.exe size:>10mb

# 布尔运算
es.exe "report and !old"
```

## HTTP API

```
GET /api/search?q=report&limit=100
GET /api/index/status
POST /api/index/rebuild
```

## 搜索语法

| 语法 | 示例 | 说明 |
|------|------|------|
| 简单搜索 | `report` | 文件名包含关键词 |
| 通配符 | `*.pdf` | 匹配模式 |
| 后缀过滤 | `ext:pdf` | 按后缀过滤 |
| 路径限定 | `path:D:\work` | 按路径过滤 |
| 大小过滤 | `size:>10mb` | 按大小过滤 |
| 时间过滤 | `date:>2026-01-01` | 按时间过滤 |
| 布尔运算 | `report and !old` | 组合搜索 |

## 配置

```toml
[ui]
hotkey = "ctrl+esc"
language = "zh"

[index]
exclude = ["C:\\Windows", "C:\\Program Files"]
realTimeMonitor = true

[search]
caseSensitive = false
defaultSort = "name"
maxResults = 100
```

## 验证契约

将 Everything-CJ 事实分为三个层级：

- **稳定能力事实**：MFT 索引、实时监控、搜索语法覆盖在此技能中。
- **验证精确事实**：精确 API 名称、签名、配置项，由 `cjpm ide`、本地文件验证。
- **未验证猜测**：从其他搜索工具（Everything、Listary）推断的行为。

永远不要将未验证猜测作为事实呈现。如果精确事实未验证，说明必须检查的内容，并提供命令或 URL。

## 常见任务

### 构建项目

```bash
cjpm build --release
```

### 运行测试

```bash
cjpm test --filter 'search'
```

### 格式化代码

```bash
cjpm fmt .
```

### 生成文档

```bash
cjpm doc
```

## 文件结构

| 文件 | 说明 |
|------|------|
| `SKILL.md` | 主技能入口 — 工作流和项目布局 |
| `README.md` | 项目概述 |
| `CHANGELOG.md` | 变更日志 |
| `CONTRIBUTING.md` | 贡献指南 |
| `docs/` | 文档目录 |
