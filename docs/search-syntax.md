# 搜索语法

Everything-CJ 支持多种搜索语法，帮助你快速定位文件。

## 基础搜索

### 简单搜索

```
输入: report
匹配: report.txt, report_2026.pdf, backup_report.docx
```

### 部分匹配

```
输入: rep
匹配: report, reporter, reproduce
```

## 通配符

| 通配符 | 说明 | 示例 |
|--------|------|------|
| `*` | 匹配任意长度字符 | `*.pdf` 所有 PDF 文件 |
| `?` | 匹配单个字符 | `report_?.txt` report_a.txt |

### 示例

```
*.pdf           # 所有 PDF 文件
report_*.txt    # report_ 开头的 txt 文件
report_?.txt    # report_ 后跟单个字符的 txt 文件
```

## 高级过滤

### 后缀过滤

```
ext:pdf        # 仅 PDF 文件
ext:docx|doc   # DOCX 或 DOC 文件
ext:~pdf       # 排除 PDF 文件
```

### 路径限定

```
path:D:\work       # D:\work 目录
path:"C:\Program Files"  # 带空格路径
path:~C:\Windows     # 排除 Windows 目录
```

### 大小过滤

```
size:>10mb          # 大于 10MB
size:<1mb           # 小于 1MB
size:1mb-10mb       # 1MB 到 10MB
size:>1gb           # 大于 1GB
```

### 时间过滤

```
datemodified:>2026-01-01  # 2026年1月1日后修改
datecreated:today         # 今天创建
datecreated:3d            # 3天内创建
datecreated:>1w           # 1周前创建
```

### 类型过滤

```
type:file       # 仅文件
type:folder     # 仅文件夹
```

## 布尔运算

### AND (与)

```
report and 2026
匹配: 同时包含 "report" 和 "2026"
```

### OR (或)

```
report or doc
匹配: 包含 "report" 或 "doc"
```

### NOT (非)

```
report and !old
匹配: 包含 "report" 但不包含 "old"
```

### 组合

```
(report or doc) and !draft
匹配: 包含 report 或 doc，但不包含 draft
```

## 组合搜索

### 示例

```
# 找 D:\work 目录下大于 10MB 的 PDF 文件
ext:pdf path:D:\work size:>10mb

# 找今天修改的文档文件
ext:docx|doc datemodified:today

# 找包含 report 但不包含 old 的文件
report and !old
```

## 搜索语法速查表

| 语法 | 示例 | 说明 |
|------|------|------|
| 简单搜索 | `report` | 文件名包含关键词 |
| 通配符 | `*.pdf` | 匹配模式 |
| 后缀过滤 | `ext:pdf` | 按后缀过滤 |
| 路径限定 | `path:D:\work` | 按路径过滤 |
| 大小过滤 | `size:>10mb` | 按大小过滤 |
| 时间过滤 | `date:>2026-01-01` | 按时间过滤 |
| 布尔运算 | `report and !old` | 组合搜索 |

---

更多信息，请参阅 [使用指南](./usage.md) 和 [API 参考](./api.md)。
