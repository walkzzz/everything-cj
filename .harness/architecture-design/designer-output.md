# Everything-CJ 架构设计文档

> **审议阶段**: 架构设计  
> **角色**: 设计者  
> **日期**: 2026-04-03  
> **状态**: 待验证

---

## 一、整体架构

### 1.1 分层架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    Everything-CJ 系统架构                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          表现层 (Presentation)                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  主窗口     │  │  CLI 工具   │  │ HTTP 服务   │            │
│  │  (Win32)    │  │  ES.exe     │  │  (8080)     │            │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘            │
└─────────┼────────────────┼────────────────┼────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                          业务层 (Business)                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    搜索引擎 (SearchEngine)                │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐           │   │
│  │  │ 查询解析  │  │ 索引查询  │  │ 结果排序  │           │   │
│  │  └───────────┘  └───────────┘  └───────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    索引引擎 (IndexEngine)                 │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐           │   │
│  │  │ MFT 读取  │  │ 文件扫描  │  │ 实时监控  │           │   │
│  │  └───────────┘  └───────────┘  └───────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                          数据层 (Data)                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  索引数据库 │  │  配置存储   │  │  缓存系统   │            │
│  │  (SQLite)   │  │  (TOML)    │  │  (Memory)   │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 模块架构

```
Everything-CJ/
├── core/                          # 核心引擎
│   ├── mft_reader.cj              # MFT 读取器
│   ├── index_engine.cj            # 索引引擎
│   └── file_monitor.cj            # 文件监控
│
├── search/                        # 搜索模块
│   ├── query_parser.cj            # 查询解析器
│   ├── index_query.cj             # 索引查询
│   └── result_ranker.cj           # 结果排序
│
├── storage/                       # 存储模块
│   ├── index_db.cj                # 索引数据库
│   └── config.cj                  # 配置管理
│
├── network/                       # 网络模块
│   ├── http_server.cj             # HTTP 服务器
│   └── api.cj                     # API 接口
│
├── ui/                            # UI 模块
│   ├── main_window.cj             # 主窗口
│   ├── search_bar.cj              # 搜索栏
│   └── result_list.cj             # 结果列表
│
└── cli/                           # CLI 工具
    ├── es.cj                      # ES.exe 命令行
    └── main.cj                    # 入口
```

---

## 二、核心模块设计

### 2.1 MFT 读取器 (core/mft_reader.cj)

**职责**: 读取 NTFS MFT 文件，解析文件记录

**接口**:
```cangjie
interface MFTReader {
    open(drive: Drive): Result<MFTHandle, MFTError>
    readAll(handle: MFTHandle): Result<MFTRecord[], MFTError>
    readDelta(handle: MFTHandle, offset: Int64): Result<MFTRecord[], MFTError>
    parseRecord(data: Byte[]): MFTRecord
}
```

**依赖**:
- stdx.fs (文件系统)
- stdx.io (IO 操作)

### 2.2 索引引擎 (core/index_engine.cj)

**职责**: 构建和管理文件索引

**接口**:
```cangjie
interface IndexEngine {
    buildIndex(drive: Drive): Result<Unit, BuildError>
    updateIndex(change: FileChangeEvent): Result<Unit, UpdateError>
    getIndexStatus(): IndexStatus
}
```

**依赖**:
- core/mft_reader.cj
- storage/index_db.cj

### 2.3 查询解析器 (search/query_parser.cj)

**职责**: 解析用户输入，生成查询计划

**接口**:
```cangjie
interface QueryParser {
    parse(input: String): QueryPlan
    validate(input: String): ValidationResult
    getSuggestions(input: String): String[]
}
```

**依赖**:
- stdx.regex (正则表达式)

### 2.4 索引数据库 (storage/index_db.cj)

**职责**: 存储和查询文件索引

**接口**:
```cangjie
interface IndexDB {
    open(path: String): Result<Unit, DBError>
    insertFile(file: FileEntry): Result<Unit, DBError>
    updateFile(file: FileEntry): Result<Unit, DBError>
    deleteFile(path: String): Result<Unit, DBError>
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError>
}
```

**依赖**:
- sqlite (SQLite 数据库)

---

## 三、数据模型

### 3.1 文件条目

```cangjie
struct FileEntry {
    id: Int64
    name: String              // 文件名
    path: String              // 完整路径
    directory: String         // 目录
    size: Int64               // 文件大小(字节)
    createTime: Int64         // 创建时间(Unix ms)
    modifyTime: Int64         // 修改时间(Unix ms)
    accessTime: Int64         // 访问时间(Unix ms)
    attributes: Int32         // 文件属性位图
    isDirectory: Bool         // 是否目录
    driveId: Int32            // 磁盘ID
}
```

### 3.2 查询计划

```cangjie
struct QueryPlan {
    keywords: String[]
    filters: Filter[]
    sortField: String
    sortOrder: String
    limit: Int32
    offset: Int32
}

enum Filter {
    Extension(String)         // ext:pdf
    Path(String)              // path:D:\work
    Size(SizeOp, Int64)       // size:>10mb
    Date(DateOp, Int64)       // date:>2026-01-01
    Type(FileType)            // type:file/folder
}
```

---

## 四、技术选型

| 组件 | 技术 | 理由 |
|------|------|------|
| 语言 | Cangjie 1.0+ | 高性能、AI原生 |
| 编译器 | cjc | 官方编译器 |
| 包管理 | cjpm | 官方包管理工具 |
| 数据库 | SQLite | 轻量、嵌入式 |
| UI | Win32 API | 原生、轻量 |
| 构建 | cjpm build | 官方构建工具 |

---

## 五、性能设计

### 5.1 索引构建

- 使用 MFT 直接读取，不遍历文件
- 批量插入数据库，减少 IO
- 路径前缀压缩，减少存储

### 5.2 搜索优化

- 倒排索引加速搜索
- 查询缓存减少重复计算
- 结果分页，按需加载

### 5.3 内存管理

- 懒加载索引数据
- 结果缓存控制大小
- 及时释放不用的资源

---

## 六、接口设计

### 6.1 CLI 接口 (ES.exe)

```bash
ES.exe [选项] <搜索词>

示例:
ES.exe report
ES.exe ext:pdf report
ES.exe size:>10mb
ES.exe "report and !old"
```

### 6.2 HTTP API

```
GET /api/search?q=report&limit=100
GET /api/index/status
POST /api/index/rebuild
```

---

**设计者签名**: ________________  
**日期**: 2026-04-03
