# 详细设计

> **审议阶段**: 编码实现 - 设计  
> **日期**: 2026-04-03  
> **状态**: 待编码

---

## 一、索引数据库设计

### 1.1 数据模型

```cangjie
struct FileEntry {
    id: Int64
    name: String
    path: String
    directory: String
    size: Int64
    createTime: Int64
    modifyTime: Int64
    accessTime: Int64
    attributes: Int32
    isDirectory: Bool
    driveId: Int32
}
```

### 1.2 数据库操作

```cangjie
class IndexDBImpl: IndexDB {
    open(path: String): Result<Unit, DBError>
    insertFile(file: FileEntry): Result<Unit, DBError>
    updateFile(file: FileEntry): Result<Unit, DBError>
    deleteFile(path: String): Result<Unit, DBError>
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError>
}
```

---

## 二、MFT 读取器设计

### 2.1 MFT 记录结构

```cangjie
struct MFTRecord {
    recordNumber: Int64
    fileName: String
    fullPath: String
    fileSize: Int64
    createTime: DateTime
    modifyTime: DateTime
    attributes: FileAttribute
    isDirectory: Bool
}
```

### 2.2 读取流程

```
1. 打开 MFT 文件
2. 读取 MFT 记录 (每条 1KB)
3. 解析 $FILE_NAME 属性
4. 解析 $STANDARD_INFORMATION 属性
5. 添加到索引
```

---

## 三、查询解析器设计

### 3.1 语法定义

```
query ::= expression ( ("and" | "or") expression )*
expression ::= ("!")? (atom | group)
atom ::= (word | wildcard | filter)
```

### 3.2 解析流程

```
1. 词法分析 (Tokenize)
2. 语法分析 (Parse)
3. 语义分析 (Analyze)
4. 生成查询计划 (Plan)
```

---

## 四、接口设计

### 4.1 CLI 接口

```bash
ES.exe [options] <query>

Options:
  -o, --output <format>   输出格式: text, csv, json
  -f, --file <path>       输出到文件
  -l, --limit <n>         限制结果数量
```

### 4.2 HTTP API

```
GET /api/search?q=report&limit=100
GET /api/index/status
POST /api/index/rebuild
```

---

**设计者签名**: ________________  
**日期**: 2026-04-03
