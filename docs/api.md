# API 参考

## HTTP API

### 基础信息

- **基础 URL**: `http://localhost:8080`
- **认证**: 无（本地访问）
- **内容类型**: `application/json`

### 端点列表

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/api/search` | 搜索文件 |
| GET | `/api/index/status` | 获取索引状态 |
| POST | `/api/index/rebuild` | 重建索引 |
| GET | `/api/config` | 获取配置 |
| PUT | `/api/config` | 更新配置 |

### 详细端点

#### GET /api/search

搜索文件。

**参数**:

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| `q` | string | 是 | 搜索词 |
| `limit` | int | 否 | 结果数量限制 (默认 100) |
| `offset` | int | 否 | 结果偏移量 (默认 0) |
| `sort` | string | 否 | 排序字段 (name/size/date) |
| `order` | string | 否 | 排序方向 (asc/desc) |

**响应**:

```json
{
  "results": [
    {
      "name": "report.docx",
      "path": "C:\\Users\\user\\Documents\\report.docx",
      "directory": "C:\\Users\\user\\Documents",
      "size": 2621440,
      "sizeFormatted": "2.5 MB",
      "createTime": 1712000000000,
      "modifyTime": 1712000000000,
      "isDirectory": false
    }
  ],
  "total": 1234,
  "time": 15
}
```

#### GET /api/index/status

获取索引状态。

**响应**:

```json
{
  "indexed": 100000,
  "drives": [
    {
      "letter": "C:",
      "label": "Windows",
      "fileSystem": "NTFS",
      "enabled": true,
      "lastIndexed": 1712000000000,
      "fileCount": 80000
    }
  ],
  "memory": 25,
  "status": "ready"
}
```

#### POST /api/index/rebuild

重建索引。

**请求**:

```json
{
  "drive": "C:",
  "full": false
}
```

**响应**:

```json
{
  "success": true,
  "message": "Index rebuild started"
}
```

## CLI API

### 命令格式

```
es.exe [选项] <搜索词>
```

### 选项

| 选项 | 简写 | 描述 | 默认值 |
|------|------|------|--------|
| `--help` | `-h` | 显示帮助 | - |
| `--version` | `-v` | 显示版本 | - |
| `--output` | `-o` | 输出格式 | text |
| `--file` | `-f` | 输出到文件 | stdout |
| `--limit` | `-l` | 限制结果数量 | 100 |
| `--json` | `-j` | JSON 格式输出 | false |
| `--csv` | `-c` | CSV 格式输出 | false |

### 输出格式

#### Text 格式

```
C:\Users\user\Documents\report.docx (2.5 MB, 2026-04-02)
D:\Work\report_2026.pdf (5.6 MB, 2026-04-01)

3 results found (15ms)
```

#### JSON 格式

```json
{
  "results": [
    {
      "name": "report.docx",
      "path": "C:\\Users\\user\\Documents\\report.docx",
      "size": 2621440,
      "modifyTime": 1712000000000
    }
  ],
  "total": 3,
  "time": 15
}
```

#### CSV 格式

```csv
name,path,size,modifyTime
report.docx,C:\Users\user\Documents\report.docx,2621440,2026-04-02T10:30:00
```

## 错误处理

### 错误码

| 错误码 | HTTP 状态码 | 描述 |
|--------|-------------|------|
| `SUCCESS` | 200 | 成功 |
| `INVALID_QUERY` | 400 | 无效查询 |
| `INDEX_NOT_READY` | 503 | 索引未就绪 |
| `PERMISSION_DENIED` | 403 | 权限不足 |
| `INTERNAL_ERROR` | 500 | 内部错误 |

### 错误响应格式

```json
{
  "error": {
    "code": "INVALID_QUERY",
    "message": "Invalid search query",
    "details": "Query cannot be empty"
  }
}
```

---

更多信息，请参阅 [使用指南](./usage.md) 和 [搜索语法](./search-syntax.md)。
