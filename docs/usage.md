# 使用指南

## 安装

### 下载发布包

1. 访问 [Releases 页面](https://gitcode.com/hw_aishell_projects/everything_cli/releases)
2. 下载适合你系统的版本
3. 解压到任意目录

### 从源码构建

```bash
# 克隆仓库
git clone https://gitcode.com/hw_aishell_projects/everything_cli.git

# 进入项目目录
cd everything_cli

# 构建
cjpm build --release

# 运行
./target/release/Everything-CJ.exe
```

## 快速开始

### 首次启动

1. 启动 Everything-CJ
2. 程序会自动索引 C/D 盘（约 1 秒）
3. 搜索栏输入关键词，实时显示结果

### 基本搜索

```bash
# 简单搜索
es.exe report

# 后缀过滤
es.exe ext:pdf report

# 大小过滤
es.exe size:>10mb

# 路径限定
es.exe path:D:\work report
```

## 命令行工具

### 基本用法

```
es.exe [选项] <搜索词>
```

### 选项

| 选项 | 简写 | 描述 |
|------|------|------|
| `--help` | `-h` | 显示帮助 |
| `--output <format>` | `-o` | 输出格式 (text/csv/json) |
| `--file <path>` | `-f` | 输出到文件 |
| `--limit <n>` | `-l` | 限制结果数量 |
| `--json` | `-j` | JSON 格式输出 |
| `--csv` | `-c` | CSV 格式输出 |

### 示例

```bash
# 搜索 PDF 文件
es.exe ext:pdf

# 搜索大于 100MB 的文件
es.exe size:>100mb

# 搜索今天修改的文件
es.exe datemodified:today

# 导出结果到 CSV
es.exe report -o csv -f results.csv
```

## HTTP API

### 启动服务

```bash
# 默认端口 8080
Everything-CJ --http-port 8080
```

### API 端点

#### 搜索文件

```
GET /api/search?q=keyword&limit=100
```

#### 获取索引状态

```
GET /api/index/status
```

#### 重建索引

```
POST /api/index/rebuild
```

### 使用示例

```bash
# 搜索
curl "http://localhost:8080/api/search?q=report"

# 索引状态
curl "http://localhost:8080/api/index/status"
```

## 配置

### 配置文件位置

- 便携版：程序目录 `config.toml`
- 安装版：`%APPDATA%\Everything-CJ\config.toml`

### 配置示例

```toml
[ui]
hotkey = "ctrl+esc"
language = "zh"

[index]
exclude = [
    "C:\\Windows",
    "C:\\Program Files",
    "C:\\Temp"
]
realTimeMonitor = true

[search]
caseSensitive = false
defaultSort = "name"
maxResults = 100
```

## 常见问题

### 搜索不到文件？

1. 检查文件是否在排除列表中
2. 检查文件所在磁盘是否已索引
3. 尝试重建索引

### 索引太慢？

1. 排除不需要的目录
2. 关闭实时监控（仅手动索引）
3. 使用 SSD 磁盘

### 内存占用高？

1. 减少索引范围
2. 排除大目录
3. 减少缓存大小

---

更多信息，请参阅 [搜索语法](./search-syntax.md) 和 [API 参考](./api.md)。
