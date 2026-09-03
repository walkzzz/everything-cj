# Everything-CJ v1.0.0 发布说明

## 概述

Everything-CJ 仓颉版首次发布！基于 NTFS MFT 实现毫秒级文件名检索。

## 主要功能

### 核心引擎
- MFT 读取器：支持 NTFS MFT 文件读取
- 索引引擎：支持秒级索引构建
- 文件监控：支持实时文件变更监控

### 搜索模块
- 查询解析器：支持高级搜索语法
- 索引查询：支持快速文件搜索
- 结果排序：支持多维度排序

### 存储模块
- 索引数据库：基于 SQLite 的索引存储
- 配置管理：支持 TOML 配置文件

### 接口模块
- CLI 工具：ES.exe 命令行搜索
- HTTP API：支持 Web 搜索接口

## 性能指标

| 指标 | 目标值 |
|------|--------|
| 索引构建 | < 1秒 (10万文件) |
| 搜索响应 | < 100ms |
| 内存占用 | < 50MB (10万文件) |
| 软件体积 | < 500KB |

## 搜索语法

```
# 简单搜索
es.exe report

# 后缀过滤
es.exe ext:pdf report

# 大小过滤
es.exe size:>10mb

# 布尔运算
es.exe "report and !old"
```

## 安装

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

### 下载发布包

即将发布...

## 贡献

请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解贡献流程。

## 许可证

MIT License

## 联系方式

- 官网: https://cangjie-lang.cn/
- 论坛: https://atomgit.com/Cangjie/UsersForum
- 邮箱: cjpkg@mail.cangjie-lang.cn
