# 常见问题

## 索引问题

### Q1: 搜索不到文件？

**可能原因**：
1. 文件在排除列表中
2. 文件所在磁盘未索引
3. 权限不足

**解决方案**：
```bash
# 检查排除列表
Everything-CJ --list-excludes

# 检查磁盘状态
Everything-CJ --index-status

# 以管理员身份运行
Everything-CJ --admin
```

### Q2: 索引太慢？

**可能原因**：
1. 首次索引需要扫描 MFT
2. 磁盘繁忙
3. 索引文件太多

**解决方案**：
```bash
# 排除不需要的目录
# 编辑 config.toml
[index]
exclude = ["C:\\Windows", "C:\\Program Files"]

# 关闭实时监控
[index]
realTimeMonitor = false
```

### Q3: 索引损坏？

**解决方案**：
```bash
# 重建索引
Everything-CJ --rebuild-index
```

## 搜索问题

### Q4: 搜索无结果？

**检查**：
1. 搜索词是否正确
2. 是否有匹配的过滤条件
3. 索引是否包含该文件

### Q5: 搜索结果不准确？

**检查**：
1. 是否启用了大小写敏感
2. 是否使用了错误的过滤条件
3. 索引是否最新

### Q6: 搜索慢？

**检查**：
1. 搜索词是否过于宽泛
2. 是否使用了复杂的过滤条件
3. 索引是否过大

## 性能问题

### Q7: 内存占用高？

**解决方案**：
1. 减少索引范围
2. 排除大目录
3. 减少缓存大小

```toml
[search]
maxResults = 50
```

### Q8: CPU 占用高？

**解决方案**：
1. 关闭实时监控
2. 减少索引频率
3. 排除不需要的目录

## 权限问题

### Q9: 提示权限不足？

**解决方案**：
```bash
# 以管理员身份运行
Everything-CJ --admin

# 或右键选择 "以管理员身份运行"
```

### Q10: 部分文件无法索引？

**可能原因**：
1. 文件在受保护目录
2. 文件被其他程序占用
3. 文件权限不足

**解决方案**：
1. 以管理员身份运行
2. 关闭占用文件的程序
3. 检查文件权限

## 其他问题

### Q11: 如何备份索引？

**解决方案**：
```bash
# 备份索引文件
cp everything.db everything.db.backup
```

### Q12: 如何恢复索引？

**解决方案**：
```bash
# 恢复索引文件
cp everything.db.backup everything.db
```

### Q13: 如何卸载？

**便携版**：
```bash
# 删除程序目录
rm -rf Everything-CJ/
```

**安装版**：
```bash
# 使用控制面板卸载
# 或运行安装程序选择卸载
```

### Q14: 如何获取日志？

**解决方案**：
```bash
# 启用日志
Everything-CJ --log-level debug

# 日志文件位置
# 便携版: 程序目录\everything.log
# 安装版: %APPDATA%\Everything-CJ\everything.log
```

---

如果以上问题无法解决，请访问 [GitHub Issues](https://gitcode.com/hw_aishell_projects/everything_cli/issues) 提交问题。
