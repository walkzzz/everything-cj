// CLI 工具
// cli/es.cj

import stdx.io.*
import search.query_parser.*
import storage.index_db.*

main() {
    let args = getArgs()
    
    if args.length == 0 {
        println("Everything-CJ v1.0")
        println("Usage: es.exe [options] <query>")
        println("")
        println("Options:")
        println("  -o, --output <format>  Output format: text, csv, json")
        println("  -f, --file <path>      Output to file")
        println("  -l, --limit <n>        Limit results")
        println("  -j, --json             JSON output")
        println("  -c, --csv              CSV output")
        println("  -h, --help             Show help")
        println("")
        println("Examples:")
        println("  es.exe report")
        println("  es.exe ext:pdf report")
        println("  es.exe size:>10mb")
        println("  es.exe \"report and !old\"")
        return
    }
    
    let query = args[0]
    let parser = QueryParserImpl()
    let plan = parser.parse(query)
    
    let db = IndexDBImpl()
    db.open("everything.db")
    
    let results = db.search(query, SearchOptions {
        limit: 100,
        sort: "name",
        order: "asc"
    })
    
    if results.isOk() {
        let resultList = results.unwrap()
        
        for result in resultList {
            println("${result.name} (${result.size}) - ${result.path}")
        }
        
        println("")
        println("${resultList.length} results found")
    } else {
        println("Error: ${results.unwrapErr()}")
    }
}
