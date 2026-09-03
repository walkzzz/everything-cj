package everything_cj

// Everything-CJ 主入口
// 基于 NTFS MFT 实现毫秒级全盘文件定位

main(): Int64 {
    println("Everything-CJ v1.0.0 (仓颉版)")
    println("毫秒级全盘文件搜索工具")
    println("")
    println("用法: es [选项] <搜索词>")
    println("")
    println("选项:")
    println("  -h, --help     显示帮助")
    println("  -v, --version  显示版本")
    println("")
    println("搜索语法:")
    println("  es report              搜索文件名包含 report")
    println("  es ext:pdf             搜索 PDF 文件")
    println("  es ext:pdf report      搜索文件名包含 report 的 PDF 文件")
    println("  es size:>10mb          搜索大于 10MB 的文件")
    println("")
    println("示例:")
    println("  es *.txt               搜索所有文本文件")
    println("  es ext:jpg             搜索所有 JPG 图片")
    return 0
}
