# Everything-CJ 技术设计文档

> **审议阶段**: 技术设计  
> **角色**: 设计者  
> **日期**: 2026-04-03  
> **状态**: 待验证

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
-- 文件索引表
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

-- 磁盘表
CREATE TABLE drives (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    letter TEXT UNIQUE,
    label TEXT,
    file_system TEXT,
    is_ntfs INTEGER DEFAULT 0,
    enabled INTEGER DEFAULT 1,
    last_indexed INTEGER
);

-- 排除列表
CREATE TABLE exclusions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE,
    type INTEGER DEFAULT 0,
    created INTEGER
);

-- 元数据表
CREATE TABLE metadata (
    key TEXT PRIMARY KEY,
    value TEXT
);

-- 索引
CREATE INDEX idx_files_name ON files(name);
CREATE INDEX idx_files_directory ON files(directory);
CREATE INDEX idx_files_size ON files(size);
CREATE INDEX idx_files_modify_time ON files(modify_time);
```

### 2.2 数据访问层

```cangjie
// storage/index_db.cj
import sqlite.*

class IndexDBImpl: IndexDB {
    private var db: Database?
    
    open(path: String): Result<Unit, DBError> {
        db = SQLite.open(path)
        db.execute(CREATE_FILES_TABLE)
        db.execute(CREATE_DRIVES_TABLE)
        db.execute(CREATE_EXCLUSIONS_TABLE)
        db.execute(CREATE_METADATA_TABLE)
        return Ok(())
    }
    
    insertFile(file: FileEntry): Result<Unit, DBError> {
        let sql = """
            INSERT OR REPLACE INTO files 
            (name, path, directory, size, create_time, modify_time, is_directory, drive_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        db.execute(sql, [
            file.name, file.path, file.directory,
            file.size, file.createTime, file.modifyTime,
            file.isDirectory, file.driveId
        ])
        return Ok(())
    }
    
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError> {
        let sql = """
            SELECT * FROM files 
            WHERE name LIKE ?
            ORDER BY ${options.sort} ${options.order}
            LIMIT ? OFFSET ?
        """
        let pattern = "%" + query + "%"
        let results = db.query(sql, [pattern, options.limit, options.offset])
        return Ok(results)
    }
}
```

---

## 三、MFT 读取器设计

### 3.1 MFT 记录解析

```cangjie
// core/mft_reader.cj
import stdx.fs.*
import stdx.io.*

class MFTReaderImpl: MFTReader {
    open(drive: Drive): Result<MFTHandle, MFTError> {
        let path = "\\.\" + drive + "\$MFT"
        return File.open(path, OpenMode.READ)
    }
    
    readAll(handle: MFTHandle): Result<MFTRecord[], MFTError> {
        let records = ArrayList<MFTRecord>()
        
        while true {
            let data = handle.read(1024)
            if data.length == 0 {
                break
            }
            
            let record = parseRecord(data)
            if record.fileName != "" {
                records.add(record)
            }
        }
        
        return Ok(records)
    }
    
    parseRecord(data: Byte[]): MFTRecord {
        // 解析 MFT 记录
        // 1. 检查签名 "FILE"
        // 2. 解析 $FILE_NAME 属性
        // 3. 解析 $STANDARD_INFORMATION 属性
        // 4. 解析 $DATA 属性
        // ...
    }
}
```

### 3.2 增量读取

```cangjie
readDelta(handle: MFTHandle, offset: Int64): Result<MFTRecord[], MFTError> {
    handle.seek(offset)
    return readAll(handle)
}
```

---

## 四、查询解析器设计

### 4.1 语法定义

```
query ::= expression ( ("and" | "or") expression )*
expression ::= ("!")? (atom | group)
atom ::= (word | wildcard | filter | regex)
group ::= "(" query ")"
word ::= [a-zA-Z0-9_\-]+
wildcard ::= ("*" | "?")+
filter ::= ":" filter_type filter_value
filter_type ::= "ext" | "path" | "size" | "date" | "type"
```

### 4.2 查询解析器实现

```cangjie
// search/query_parser.cj
import stdx.regex.*

class QueryParserImpl: QueryParser {
    parse(input: String): QueryPlan {
        let plan = QueryPlan {
            keywords: ArrayList<String>()
            filters: ArrayList<Filter>()
            sortField: "name"
            sortOrder: "asc"
            limit: 100
        }
        
        let tokens = tokenize(input)
        
        for token in tokens {
            match token {
                FILTER_EXT => {
                    plan.filters.add(Filter.Extension(token.value))
                }
                FILTER_PATH => {
                    plan.filters.add(Filter.Path(token.value))
                }
                FILTER_SIZE => {
                    plan.filters.add(Filter.Size(parseSizeOp(token.value), parseSize(token.value)))
                }
                FILTER_DATE => {
                    plan.filters.add(Filter.Date(parseDateOp(token.value), parseDate(token.value)))
                }
                KEYWORD => {
                    plan.keywords.add(token.value)
                }
            }
        }
        
        return plan
    }
}
```

---

## 五、文件监控设计

### 5.1 监控实现

```cangjie
// core/file_monitor.cj
import stdx.fs.*
import stdx.sync.*

class FileMonitorImpl: FileMonitor {
    private var running: Bool = false
    private var callbacks: ArrayList<(FileChangeEvent) -> Unit>()
    private var thread: Thread?
    
    start(path: String): Result<Unit, MonitorError> {
        if running {
            return Err(MonitorError.ALREADY_RUNNING)
        }
        
        running = true
        thread = Thread.new(() => {
            monitorLoop(path)
        })
        
        return Ok(())
    }
    
    private monitorLoop(path: String): Unit {
        while running {
            let changes = readDirectoryChanges(path)
            for change in changes {
                let event = FileChangeEvent {
                    changeType: change.type,
                    path: change.path,
                    timestamp: DateTime.now()
                }
                for callback in callbacks {
                    callback(event)
                }
            }
        }
    }
}
```

---

## 六、HTTP API 设计

### 6.1 API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/api/search` | GET | 搜索文件 |
| `/api/index/status` | GET | 索引状态 |
| `/api/index/rebuild` | POST | 重建索引 |
| `/api/config` | GET/PUT | 配置管理 |

### 6.2 API 实现

```cangjie
// network/api.cj
import stdx.net.http.*

class APIHandler {
    private var db: IndexDB
    
    handleSearch(request: HTTPRequest): HTTPResponse {
        let query = request.queryParam("q")
        let limit = request.queryParam("limit").parseInt().unwrapOr(100)
        
        let results = db.search(query, SearchOptions {
            limit: limit,
            sort: "name",
            order: "asc"
        })
        
        return HTTPResponse {
            status: 200,
            body: toJson(results)
        }
    }
}
```

---

## 七、UI 设计

### 7.1 窗口布局

```
┌─────────────────────────────────────────────────────────────────┐
│  ┌─ 标题栏 ──────────────────────────────────────────────────┐ │
│  │ ═════════════════════════════════════════════════════════ │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌─ 搜索栏 ──────────────────────────────────────────────────┐ │
│  │ ┌─────────────────────────────────────────────────────┐   │ │
│  │ │ 🔍 report                                          │   │ │
│  │ └─────────────────────────────────────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌─ 结果列表 ──────────────────────────────────────────────┐ │
│  │ ┌───────────────────────────────────────────────────┐   │ │
│  │ │ 📄 report.docx          2.5 MB  2026/04/02 10:30  │   │ │
│  │ └───────────────────────────────────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌─ 状态栏 ──────────────────────────────────────────────────┐ │
│  │ 共 3 个结果 | 索引: 10万文件 | 内存: 25MB | 搜索: 15ms    │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + Esc` | 显示/隐藏主窗口 |
| `Ctrl + F` | 聚焦搜索栏 |
| `Enter` | 打开选中文件 |
| `Ctrl + O` | 打开所在文件夹 |
| `Esc` | 清除搜索/关闭窗口 |

---

## 八、配置管理

### 8.1 配置文件 (config.toml)

```toml
[ui]
hotkey = "ctrl+esc"
language = "zh"
showInTaskbar = true
minimizeToTray = true

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
defaultOrder = "asc"
maxResults = 100
```

---

**设计者签名**: ________________  
**日期**: 2026-04-03
