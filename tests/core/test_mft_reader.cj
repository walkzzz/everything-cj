// 单元测试
// tests/core/test_mft_reader.cj

import core.mft_reader.*
import std.test.*

test "MFTReader open" {
    let reader = MFTReaderImpl()
    let result = reader.open("C:")
    
    assert(result.isOk())
}

test "MFTReader parseRecord" {
    let reader = MFTReaderImpl()
    let data = createTestRecord()
    let record = reader.parseRecord(data)
    
    assert(record.fileName != "")
}
