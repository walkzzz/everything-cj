# 配置说明

## 配置文件位置

| 安装类型 | 路径 |
|----------|------|
| 便携版 | 程序目录 `config.toml` |
| 安装版 | `%APPDATA%\Everything-CJ\config.toml` |

## 配置结构

```toml
# UI 配置
[ui]
hotkey = "ctrl+esc"          # 全局快捷键
language = "zh"              # 语言 (zh/en)
showInTaskbar = true         # 显示在任务栏
minimizeToTray = true        # 最小化到托盘

# 索引配置
[index]
exclude = [                  # 排除目录
    "C:\\Windows",
    "C:\\Program Files",
    "C:\\Temp"
]
realTimeMonitor = true       # 实时监控

# 搜索配置
[search]
caseSensitive = false        # 大小写敏感
defaultSort = "name"         # 默认排序字段
defaultOrder = "asc"         # 默认排序方向
maxResults = 100             # 最大结果数

# HTTP 配置
[http]
enabled = false              # 启用 HTTP 服务
port = 8080                  # 服务端口
```

## 配置项说明

### UI 配置

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `hotkey` | string | `ctrl+esc` | 全局快捷键 |
| `language` | string | `zh` | 界面语言 |
| `showInTaskbar` | bool | `true` | 显示在任务栏 |
| `minimizeToTray` | bool | `true` | 最小化到托盘 |

### 索引配置

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `exclude` | array | `[]` | 排除目录列表 |
| `realTimeMonitor` | bool | `true` | 实时监控文件变更 |

### 搜索配置

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `caseSensitive` | bool | `false` | 大小写敏感 |
| `defaultSort` | string | `name` | 默认排序字段 |
| `defaultOrder` | string | `asc` | 默认排序方向 |
| `maxResults` | int | `100` | 最大结果数 |

### HTTP 配置

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `enabled` | bool | `false` | 启用 HTTP 服务 |
| `port` | int | `8080` | 服务端口 |

## 配置示例

### 排除目录

```toml
[index]
exclude = [
    "C:\\Windows",
    "C:\\Program Files",
    "C:\\Program Files (x86)",
    "C:\\$Recycle.Bin",
    "C:\\Temp"
]
```

### 启用 HTTP 服务

```toml
[http]
enabled = true
port = 8080
```

### 中文界面

```toml
[ui]
language = "zh"
hotkey = "ctrl+esc"
```

## 配置更新

### 自动更新

修改配置文件后，程序会自动重新加载。

### 手动刷新

```bash
# 重启程序
Everything-CJ --restart
```

## 配置验证

```bash
# 验证配置文件
Everything-CJ --validate-config
```

---

更多信息，请参阅 [使用指南](./usage.md)。
