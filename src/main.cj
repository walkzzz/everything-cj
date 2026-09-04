package everything_cj

// Everything-CJ v1.0.0 — 仓颉版毫秒级文件搜索工具
// 基于 Directory.walk 递归遍历文件系统

import std.fs.*
import std.env.*
import std.convert.*
import std.collection.*

// ── 可变计数器（绕过 lambda 不可捕获可变变量限制）──
class Counter {
    var value: Int64
    init() { value = 0 }
    func inc(): Unit { value++ }
}

// ── 搜索条件 ──
class SearchCriteria {
    let keywords: ArrayList<String>      // 文件名关键词
    let extensions: ArrayList<String>    // ext:pdf → ["pdf"]
    var sizeMin: Int64                   // size:>10mb
    var sizeMax: Int64                   // size:<1mb
    var wildcard: String                 // 通配符模式

    init() {
        keywords = ArrayList<String>()
        extensions = ArrayList<String>()
        sizeMin = Int64(0)
        sizeMax = Int64(0)
        wildcard = ""
    }

    // 检查文件是否匹配条件
    func matches(name: String, size: Int64): Bool {
        // 扩展名过滤
        if (extensions.size > 0) {
            var extMatch = false
            let lowerName = name.toAsciiLower()
            for (ext in extensions) {
                if (lowerName.endsWith("." + ext.toAsciiLower())) {
                    extMatch = true
                }
            }
            if (!extMatch) {
                return false
            }
        }

        // 大小过滤
        if (sizeMin > 0 && size < sizeMin) {
            return false
        }
        if (sizeMax > 0 && size > sizeMax) {
            return false
        }

        // 关键词过滤
        if (keywords.size > 0) {
            var allMatch = true
            let lowerName = name.toAsciiLower()
            for (kw in keywords) {
                if (!lowerName.contains(kw.toAsciiLower())) {
                    allMatch = false
                }
            }
            if (!allMatch) {
                return false
            }
        }

        // 通配符模式
        if (wildcard.size > 0) {
            if (!matchWildcard(name, wildcard)) {
                return false
            }
        }

        return true
    }
}

// ── 通配符匹配 ──
func matchWildcard(text: String, pattern: String): Bool {
    // *.ext → endsWith .ext
    if (pattern.startsWith("*")) {
        let suffix = pattern[1..pattern.size]
        return text.toAsciiLower().endsWith(suffix.toAsciiLower())
    }
    // prefix* → startsWith prefix
    if (pattern.endsWith("*")) {
        let prefix = pattern[0..(pattern.size - 1)]
        return text.toAsciiLower().startsWith(prefix.toAsciiLower())
    }
    // pre*suf → startsWith pre && endsWith suf
    if (pattern.contains("*")) {
        let starIdx = pattern.indexOf("*")
        match (starIdx) {
            case Some(idx) =>
                let prefix = pattern[0..idx]
                let suffix = pattern[(idx + 1)..pattern.size]
                let lowerText = text.toAsciiLower()
                return lowerText.startsWith(prefix.toAsciiLower()) &&
                       lowerText.endsWith(suffix.toAsciiLower())
            case None =>
                return false
        }
    }
    // 无通配符，精确匹配
    return text.toAsciiLower() == pattern.toAsciiLower()
}

// ── 解析大小字符串 ──
func parseSize(s: String): Int64 {
    let lower = s.toAsciiLower()
    if (lower.endsWith("mb")) {
        return Int64.parse(lower[0..(lower.size - 2)]) * Int64(1048576)
    } else if (lower.endsWith("kb")) {
        return Int64.parse(lower[0..(lower.size - 2)]) * Int64(1024)
    } else if (lower.endsWith("gb")) {
        return Int64.parse(lower[0..(lower.size - 2)]) * Int64(1073741824)
    } else {
        return Int64.parse(lower)
    }
}

// ── 格式化文件大小 ──
func formatSize(size: Int64): String {
    if (size >= Int64(1073741824)) {
        return "${size / Int64(1073741824)} GB"
    } else if (size >= Int64(1048576)) {
        return "${size / Int64(1048576)} MB"
    } else if (size >= Int64(1024)) {
        return "${size / Int64(1024)} KB"
    } else {
        return "${size} B"
    }
}

// ── 显示帮助 ──
func showHelp(): Unit {
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
    println("  es size:<1mb           搜索小于 1MB 的文件")
    println("  es *.txt               通配符搜索所有文本文件")
    println("")
    println("示例:")
    println("  es *.txt               搜索所有文本文件")
    println("  es ext:jpg             搜索所有 JPG 图片")
    println("  es ext:pdf size:>5mb   搜索大于 5MB 的 PDF 文件")
    println("  es config ext:json     搜索文件名含 config 的 JSON 文件")
}

// ── 主函数 ──
main(): Int64 {
    let args = getCommandLine()

    // 无参数或 --help
    if (args.size <= 1 || args[1] == "-h" || args[1] == "--help") {
        showHelp()
        return 0
    }

    // --version
    if (args[1] == "-v" || args[1] == "--version") {
        println("Everything-CJ v1.0.0 (Cangjie 1.1.3)")
        return 0
    }

    // 解析搜索条件
    let criteria = SearchCriteria()
    var searchPath = "."

    for (i in 1..args.size) {
        let arg = args[i]

        if (arg == "-h" || arg == "--help" || arg == "-v" || arg == "--version") {
            continue
        }

        // ext:pdf
        if (arg.startsWith("ext:")) {
            criteria.extensions.add(arg[4..arg.size])
        }
        // size:>10mb / size:<1mb
        else if (arg.startsWith("size:")) {
            let sizeSpec = arg[5..arg.size]
            if (sizeSpec.startsWith(">")) {
                criteria.sizeMin = parseSize(sizeSpec[1..sizeSpec.size])
            } else if (sizeSpec.startsWith("<")) {
                criteria.sizeMax = parseSize(sizeSpec[1..sizeSpec.size])
            }
        }
        // 通配符模式
        else if (arg.contains("*") || arg.contains("?")) {
            criteria.wildcard = arg
        }
        // 路径参数
        else if (arg.startsWith("/") || arg.startsWith("./") || arg == ".") {
            searchPath = arg
        }
        // 普通关键词
        else {
            criteria.keywords.add(arg)
        }
    }

    println("搜索路径: ${searchPath}")
    println("")

    // 执行搜索
    let counter = Counter()
    Directory.walk(searchPath, { info =>
        // 跳过目录，只搜索文件
        if (info.isDirectory()) {
            return true
        }

        let name = info.name
        let path = info.path.toString()
        let size = info.size

        // 匹配检查
        if (criteria.matches(name, size)) {
            println("${path}  [${formatSize(size)}]")
            counter.inc()
        }

        true
    })

    println("")
    println("找到 ${counter.value} 个文件")

    return 0
}
