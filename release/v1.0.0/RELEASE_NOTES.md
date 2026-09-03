# Everything-CJ v1.0.0 发布说明

## 概述
Everything-CJ 仓颉版首次发布！基于 NTFS MFT 实现毫秒级文件名检索。

## 二进制信息
- 文件: everything-cj-linux-aarch64
- 架构: ARM64 (aarch64)
- 大小: 1.1MB
- 构建工具: Cangjie Compiler 1.1.3 (cjnative)

## 功能
- MFT 读取器: 毫秒级文件索引
- 搜索引擎: 支持通配符、正则表达式
- 实时监控: 文件变更自动更新

## 用法
```bash
# 显示帮助
./everything-cj-linux-aarch64

# 搜索文件
./everything-cj-linux-aarch64 report

# 按扩展名搜索
./everything-cj-linux-aarch64 ext:pdf
```

## 构建
```bash
cjpm build
# 产物: target/release/bin/main
```
