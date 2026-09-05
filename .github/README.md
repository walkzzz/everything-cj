# GitHub Actions CI/CD

本目录包含 Everything-CJ 的多平台自动构建配置。

## Workflow 文件

### `build.yml` — 全平台构建

在推送 `v*` 标签或手动触发时，同时在 4 个平台构建二进制：

| Runner | 目标平台 | 构建方式 |
|--------|---------|---------|
| `ubuntu-22.04` | Linux x64 | 原生编译 |
| `macos-14` | macOS ARM64 (Apple Silicon) | 原生编译 |
| `macos-13` | macOS x64 (Intel) | 原生编译 |
| `ubuntu-22.04` | Windows x64 | 交叉编译 |

构建完成后自动创建 GitHub Release，上传所有二进制和校验文件。

### `build-macos.yml` — 仅 macOS 构建

单独的 macOS 构建 workflow，用于只需要 macOS 二进制时手动触发。

## 使用方法

### 自动触发（推送标签）

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 手动触发

在 GitHub 仓库页面 → Actions → 选择 workflow → Run workflow

## 前提条件

1. **GitHub 仓库**：需要将代码镜像到 GitHub（当前主仓库在 GitCode）
2. **macOS Runner**：GitHub Actions 免费提供 `macos-14` 和 `macos-13` runner
3. **SDK 下载**：workflow 会自动从 cangjie-lang.cn 下载仓颉 SDK 1.1.3

## GitCode 镜像到 GitHub

```bash
# 添加 GitHub 远程
git remote add github https://github.com/<user>/everything-cj.git

# 推送代码
git push github master

# 推送标签触发构建
git push github v1.0.0
```

## 构建产物

```
everything-cj-v1.0.0-linux-x64.tar.gz
everything-cj-v1.0.0-macos-aarch64.tar.gz
everything-cj-v1.0.0-macos-x64.tar.gz
everything-cj-v1.0.0-windows-x64.tar.gz
```
