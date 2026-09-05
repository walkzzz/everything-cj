# Everything-CJ

> **仓颉版 Everything 搜索工具** - 毫秒级全盘文件定位

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/language-Cangjie-orange.svg)](https://cangjie-lang.cn/)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)]()

## ✨ 特性

- ⚡ **极速搜索**: 基于 NTFS MFT 秒级索引，搜索响应 <100ms
- 💾 **低内存占用**: 数十万文件索引内存占用 <50MB
- 🔍 **高级搜索**: 支持通配符、布尔运算、大小/时间过滤
- 📁 **实时监控**: 文件变更自动更新索引
- 🖥️ **CLI 工具**: ES.exe 命令行搜索
- 🌐 **HTTP API**: 支持 Web 搜索接口

## 🚀 快速开始

### 安装

#### 下载发布包

```bash
# 从 GitHub Releases 下载
# 解压到任意目录
```

#### 从源码构建

```bash
# 克隆仓库
git clone https://gitcode.com/hw_aishell_projects/everything_cli.git

# 进入项目目录
cd everything_cli

# 构建
cjpm build --release
```

### 使用

#### 命令行工具

```bash
# 简单搜索
./es.exe report

# 后缀过滤
./es.exe ext:pdf report

# 大小过滤
./es.exe size:>10mb

# 布尔运算
./es.exe "report and !old"
```

#### HTTP API

```bash
# 启动 HTTP 服务
./Everything-CJ --http-port 8080

# 搜索
curl "http://localhost:8080/api/search?q=report"
```

## 📖 文档

- [使用指南](./docs/usage.md)
- [搜索语法](./docs/search-syntax.md)
- [API 参考](./docs/api.md)
- [配置说明](./docs/configuration.md)
- [常见问题](./docs/faq.md)

## 🔧 构建配置

### 系统要求

- Windows 10/11
- Cangjie 1.0+
- cjpm 1.0+

### 依赖

| 依赖 | 版本 |
|------|------|
| stdx | 1.0+ |
| sqlite | 3.x |

## 🤝 贡献

请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解贡献流程。

## 📜 变更日志

参见 [CHANGELOG.md](CHANGELOG.md) 了解版本变更历史。

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。
