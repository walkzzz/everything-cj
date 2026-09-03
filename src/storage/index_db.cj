// 索引数据库
// storage/index_db.cj

import sqlite.*

/// 索引数据库接口
interface IndexDB {
    open(path: String): Result<Unit, DBError>
    close(): Result<Unit, DBError>
    insertFile(file: FileEntry): Result<Unit, DBError>
    updateFile(file: FileEntry): Result<Unit, DBError>
    deleteFile(path: String): Result<Unit, DBError>
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError>
    getFileCount(): Result<Int64, DBError>
    beginTransaction(): Result<Unit, DBError>
    commit(): Result<Unit, DBError>
}

/// 索引数据库实现
class IndexDBImpl: IndexDB {
    private var db: Database?
    
    open(path: String): Result<Unit, DBError> {
        db = SQLite.open(path)
        
        db.execute("""
            CREATE TABLE IF NOT EXISTS files (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                path TEXT NOT NULL,
                directory TEXT NOT NULL,
                size INTEGER DEFAULT 0,
                create_time INTEGER,
                modify_time INTEGER,
                is_directory INTEGER DEFAULT 0,
                drive_id INTEGER,
                UNIQUE(path) ON CONFLICT REPLACE
            )
        """)
        
        db.execute("CREATE INDEX IF NOT EXISTS idx_files_name ON files(name)")
        db.execute("CREATE INDEX IF NOT EXISTS idx_files_directory ON files(directory)")
        
        return Ok(())
    }
    
    close(): Result<Unit, DBError> {
        db.close()
        return Ok(())
    }
    
    insertFile(file: FileEntry): Result<Unit, DBError> {
        let sql = """
            INSERT OR REPLACE INTO files 
            (name, path, directory, size, create_time, modify_time, is_directory, drive_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        db.execute(sql, [
            file.name, file.path, file.directory,
            file.size, file.createTime, file.modifyTime,
            file.isDirectory, file.driveId
        ])
        
        return Ok(())
    }
    
    updateFile(file: FileEntry): Result<Unit, DBError> {
        return insertFile(file)
    }
    
    deleteFile(path: String): Result<Unit, DBError> {
        db.execute("DELETE FROM files WHERE path = ?", [path])
        return Ok(())
    }
    
    search(query: String, options: SearchOptions): Result<SearchResult[], DBError> {
        let sql = """
            SELECT * FROM files 
            WHERE name LIKE ?
            ORDER BY ${options.sort} ${options.order}
            LIMIT ? OFFSET ?
        """
        
        let pattern = "%" + query + "%"
        let results = db.query(sql, [
            pattern, options.limit, options.offset
        ])
        
        return Ok(results)
    }
    
    getFileCount(): Result<Int64, DBError> {
        let result = db.query("SELECT COUNT(*) FROM files", [])
        return Ok(result[0][0].toInt64())
    }
    
    beginTransaction(): Result<Unit, DBError> {
        db.execute("BEGIN TRANSACTION", [])
        return Ok(())
    }
    
    commit(): Result<Unit, DBError> {
        db.execute("COMMIT", [])
        return Ok(())
    }
}
