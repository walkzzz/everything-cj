// Everything-CJ 主入口
// main.cj

import stdx.log.*
import core.mft_reader.*
import core.index_engine.*
import storage.index_db.*

main() {
    // 初始化日志
    log.setLevel(LogLevel.INFO)
    log.info("Everything-CJ starting...")
    
    // 打开索引数据库
    let db = IndexDBImpl()
    db.open("everything.db")
    
    // 构建索引
    let engine = IndexEngineImpl(db)
    engine.buildIndex("C:")
    
    // 启动监控
    let monitor = FileMonitorImpl()
    monitor.start("C:")
    
    // 启动 CLI
    let cli = CLI()
    cli.run()
}
