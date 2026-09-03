// 索引引擎
// core/index_engine.cj

import core.mft_reader.*
import storage.index_db.*

/// 索引引擎接口
interface IndexEngine {
    buildIndex(drive: Drive): Result<Unit, BuildError>
    updateIndex(change: FileChangeEvent): Result<Unit, UpdateError>
    getIndexStatus(): IndexStatus
}

/// 索引引擎实现
class IndexEngineImpl: IndexEngine {
    private var db: IndexDB
    private var reader: MFTReader
    
    constructor(db: IndexDB) {
        this.db = db
        this.reader = MFTReaderImpl()
    }
    
    buildIndex(drive: Drive): Result<Unit, BuildError> {
        let handle = reader.open(drive)
        let records = reader.readAll(handle)
        
        db.beginTransaction()
        
        for record in records {
            let file = FileEntry {
                name: record.fileName,
                path: record.fullPath,
                size: record.fileSize,
                createTime: record.createTime.timestamp(),
                modifyTime: record.modifyTime.timestamp(),
                isDirectory: record.isDirectory,
                driveId: 0
            }
            db.insertFile(file)
        }
        
        db.commit()
        
        return Ok(())
    }
    
    updateIndex(change: FileChangeEvent): Result<Unit, UpdateError> {
        match change.changeType {
            FILE_ADDED => {
                db.insertFile(change.file)
            }
            FILE_REMOVED => {
                db.deleteFile(change.path)
            }
            FILE_MODIFIED => {
                db.updateFile(change.file)
            }
        }
        
        return Ok(())
    }
    
    getIndexStatus(): IndexStatus {
        let count = db.getFileCount()
        return IndexStatus {
            fileCount: count,
            lastUpdate: DateTime.now()
        }
    }
}
