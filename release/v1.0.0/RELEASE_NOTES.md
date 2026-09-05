# Everything-CJ v1.0.0 发布说明

## 概述
Everything-CJ 仓颉版首次发布！基于 NTFS MFT 实现毫秒级文件名检索。

## 二进制文件

| 平台 | 文件 | 架构 | 大小 |
|------|------|------|------|
| Linux | everything-cj-linux-aarch64 | ARM64 | 1.1 MB |
| Windows | everything-cj-windows-x64.exe | x86_64 | 951 KB |
| macOS | - | - | 需在 macOS 上构建 |

## 构建环境
- 编译器: Cangjie Compiler 1.1.3 (cjnative)
- 构建主机: Linux aarch64 (Huawei Cloud EulerOS 2.0)
- Linux 二进制: 原生编译
- Windows 二进制: 交叉编译 (--target x86_64-pc-windows-gnu)
- macOS: 需要 macOS 机器构建 (缺少 libSystem)

## 功能
- MFT 读取器: 毫秒级文件索引
- 搜索引擎: 支持通配符、正则表达式
- 实时监控: 文件变更自动更新

## 用法
```bash
# Linux
./everything-cj-linux-aarch64

# Windows
everything-cj-windows-x64.exe

# 搜索文件
es report
es ext:pdf
es size:>10mb
```

## 构建
```bash
# Linux (原生)
cjpm build

# Windows (交叉编译)
cjc src/main.cj --target x86_64-pc-windows-gnu -o everything-cj.exe
```
