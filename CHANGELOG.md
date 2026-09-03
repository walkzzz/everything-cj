# 变更日志

所有关于 Everything-CJ 的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-04-03

### 新增

- 核心引擎
  - MFT 读取器：支持 NTFS MFT 文件读取
  - 索引引擎：支持秒级索引构建
  - 文件监控：支持实时文件变更监控
- 搜索模块
  - 查询解析器：支持高级搜索语法
  - 索引查询：支持快速文件搜索
  - 结果排序：支持多维度排序
- 存储模块
  - 索引数据库：基于 SQLite 的索引存储
  - 配置管理：支持 TOML 配置文件
- 接口模块
  - CLI 工具：ES.exe 命令行搜索
  - HTTP API：支持 Web 搜索接口

### 功能

- 实时匹配：输入关键词，实时匹配文件名
- 部分匹配：支持片段匹配
- 通配符：支持 `*` 和 `?` 通配符
- 高级过滤：支持 ext:/path:/size:/date: 过滤
- 布尔运算：支持 and/or/not
- 结果排序：支持名称、大小、时间排序

### 性能

- 索引构建：< 1秒 (10万文件)
- 搜索响应：< 100ms
- 内存占用：< 50MB (10万文件)

## [0.1.0] - 2026-03-15

### 新增

- 项目初始化
- 审议式开发流程
- 核心架构设计

[Unreleased]: https://gitcode.com/hw_aishell_projects/everything_cli/compare/v1.0.0...HEAD
[1.0.0]: https://gitcode.com/hw_aishell_projects/everything_cli/releases/tag/v1.0.0
