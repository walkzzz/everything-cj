# Everything-CJ 技术设计文档（最终版）

> **审议阶段**: 技术设计  
> **审议模式**: 设计者 ↔ 验证者  
> **状态**: ✅ 已达成一致  
> **日期**: 2026-04-03

---

## 一、技术选型

### 1.1 语言与编译器

| 组件 | 版本 | 理由 |
|------|------|------|
| Cangjie | 1.0+ | 高性能、AI原生、官方支持 |
| cjc | 1.0+ | 官方编译器，支持多平台 |
| cjpm | 1.0+ | 官方包管理工具 |

### 1.2 依赖库

| 库 | 用途 | 版本 |
|------|------|------|
| stdx.fs | 文件系统操作 | 1.0+ |
| stdx.io | IO 操作 | 1.0+ |
| stdx.net.http | HTTP 服务器 | 1.0+ |
| stdx.log | 日志记录 | 1.0+ |
| sqlite | 数据库 | 3.x |

---

## 二、数据库设计

### 2.1 SQLite Schema

```sql
CREATE TABLE files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    path TEXT NOT NULL,
    directory TEXT NOT NULL,
    size INTEGER DEFAULT 0,
    create_time INTEGER,
    modify_time INTEGER,
    access_time INTEGER,
    attributes INTEGER DEFAULT 0,
    is_directory INTEGER DEFAULT 0,
    drive_id INTEGER,
    mft_record INTEGER,
    UNIQUE(path) ON CONFLICT REPLACE
);

CREATE TABLE drives (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    letter TEXT UNIQUE,
    label TEXT,
    file_system TEXT,
    is_ntfs INTEGER DEFAULT 0,
    enabled INTEGER DEFAULT 1,
    last_indexed INTEGER
);

CREATE TABLE exclusions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE,
    type INTEGER DEFAULT 0,
    created INTEGER
);

CREATE TABLE metadata (
    key TEXT PRIMARY KEY,
    value TEXT
);

CREATE INDEX idx_files_name ON files(name);
CREATE INDEX idx_files_directory ON files(directory);
CREATE INDEX idx_files_size ON files(size);
CREATE INDEX idx_files_modify_time ON files(modify_time);
```

---

## 三、核心模块设计

### 3.1 MFT 读取器

```cangjie
interface MFTReader {
    open(drive: Drive): Result<MFTHandle, MFTError>
    readAll(handle: MFTHandle): Result<MFTRecord[], MFTError>
    readDelta(handle: MFTHandle, offset: Int64): Result<MFTRecord[], MFTError>
    parseRecord(data: Byte[]): MFTRecord
}
```

### 3.2 查询解析器

```cangjie
interface QueryParser {
    parse(input: String): QueryPlan
    validate(input: String): ValidationResult
    getSuggestions(input: String): String[]
}
```

### 3.3 索引数据库

```cangjie
interface IndexDB {
    open(path: String): Result<Unit, DBError>
    insertFile(file: FileEntry): Result<Unit, DBError>
    updateFile(file: FileEntry): Result<Unit, DBError>
    deleteFile(path: String): Result<Unit, DBError>
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError>
}
```

---

## 四、API 设计

### 4.1 CLI 接口

```bash
ES.exe [选项] <搜索词>

示例:
ES.exe report
ES.exe ext:pdf report
ES.exe size:>10mb
ES.exe "report and !old"
```

### 4.2 HTTP API

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/search` | GET | 搜索文件 |
| `/api/index/status` | GET | 索引状态 |
| `/api/index/rebuild` | POST | 重建索引 |
| `/api/config` | GET/PUT | 配置管理 |

---

## 五、配置管理

### 5.1 配置文件 (config.toml)

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

---

## 六、测试计划

### 6.1 单元测试

| 模块 | 测试内容 |
|------|----------|
| MFT 读取器 | 打开、读取、解析 |
| 查询解析器 | 语法解析、验证 |
| 索引数据库 | 插入、更新、搜索 |

### 6.2 集成测试

| 场景 | 测试内容 |
|------|----------|
| 完整流程 | 构建索引 → 搜索 |
| 实时监控 | 文件变更 → 索引更新 |
| CLI 工具 | 命令行搜索 |

---

**设计者签名**: ________________  
**验证者签名**: ________________  
**日期**: 2026-04-03  
**状态**: ✅ 已达成一致
