// 查询解析器
// search/query_parser.cj

import stdx.regex.*

/// 查询计划
struct QueryPlan {
    keywords: String[]
    filters: Filter[]
    sortField: String
    sortOrder: String
    limit: Int32
}

/// 过滤器
enum Filter {
    Extension(String)      // ext:pdf
    Path(String)           // path:D:\work
    Size(SizeOp, Int64)    // size:>10mb
    Date(DateOp, Int64)    // date:>2026-01-01
    Type(FileType)         // type:file/folder
}

/// 查询解析器接口
interface QueryParser {
    parse(input: String): QueryPlan
    validate(input: String): ValidationResult
    getSuggestions(input: String): String[]
}

/// 查询解析器实现
class QueryParserImpl: QueryParser {
    parse(input: String): QueryPlan {
        let plan = QueryPlan {
            keywords: ArrayList<String>()
            filters: ArrayList<Filter>()
            sortField: "name"
            sortOrder: "asc"
            limit: 100
        }
        
        let tokens = tokenize(input)
        
        for token in tokens {
            if token.type == "filter" {
                let filter = parseFilter(token.value)
                plan.filters.add(filter)
            } else if token.type == "keyword" {
                plan.keywords.add(token.value)
            }
        }
        
        return plan
    }
    
    validate(input: String): ValidationResult {
        if input.length == 0 {
            return ValidationResult(false, "Query cannot be empty")
        }
        
        return ValidationResult(true, "")
    }
    
    getSuggestions(input: String): String[] {
        let suggestions = ArrayList<String>()
        
        if input.length > 0 {
            suggestions.add("ext:pdf")
            suggestions.add("path:D:\\work")
            suggestions.add("size:>10mb")
        }
        
        return suggestions
    }
    
    private tokenize(input: String): Token[] {
        let tokens = ArrayList<Token>()
        let parts = input.split(" ")
        
        for part in parts {
            if part.contains(":") {
                tokens.add(Token("filter", part))
            } else {
                tokens.add(Token("keyword", part))
            }
        }
        
        return tokens
    }
    
    private parseFilter(value: String): Filter {
        let parts = value.split(":")
        let filterType = parts[0]
        let filterValue = parts[1]
        
        match filterType {
            "ext" => return Filter.Extension(filterValue)
            "path" => return Filter.Path(filterValue)
            "size" => return Filter.Size(parseSizeOp(filterValue), parseSize(filterValue))
            "date" => return Filter.Date(parseDateOp(filterValue), parseDate(filterValue))
            "type" => return Filter.Type(parseFileType(filterValue))
            _ => return Filter.Extension("")
        }
    }
}
