//
//  QRMetaData.swift
//  QRPlayerMac
//
//  Created by Wesley Yang on 2017/10/27.
//  Copyright © 2017年 ff. All rights reserved.
//

#if os(iOS)
import Foundation
#else
import Cocoa
#endif

//encode
// data -> string(64) -> data(from string(64)) -> QR
//decode
// QR -> string(64) -> data




struct QRMetaData {
    var fileName : String
    var fileSize : UInt32
    var payload : Data
    
    struct QRMetaMetaData {
        var fileNameLen : UInt8
        var fileSize : UInt32
    }
    
    func encode() -> Data {
        var metaStruct = QRMetaMetaData(fileNameLen: UInt8(fileName.lengthOfBytes(using: .utf8)), fileSize: fileSize)
        var data = Data()
        let meta = Data.init(bytes:&metaStruct,count:MemoryLayout<QRMetaMetaData>.size)
        data.append(meta)
        data.append(fileName.data(using: .utf8)!)
        data.append(payload)
        return data
    }
    
    static func encodeHeaderSize() -> Int {
        return MemoryLayout<QRMetaMetaData>.size
    }

    static  func decode(data:Data) -> QRMetaData {
        var metaStruct = QRMetaMetaData(fileNameLen: 0, fileSize: 0)
        let metaSize = MemoryLayout<QRMetaMetaData>.size
        (data as NSData).getBytes(&metaStruct, range: NSMakeRange(0, metaSize))
        let fileNameData = data.subdata(in: metaSize ..< metaSize+Int(metaStruct.fileNameLen))
        let fileName = String.init(data: fileNameData, encoding: .utf8)!
        let payload = data.subdata(in: metaSize+Int(metaStruct.fileNameLen) ..< data.count)
        return QRMetaData(fileName: fileName, fileSize: metaStruct.fileSize, payload: payload)
    }
    
}

struct QRPageData : CustomStringConvertible{
    var index: UInt16
    var numOfPackets : UInt16
    var payload : Data
    
    struct QRPageMetaData {
        var index : UInt16
        var numOfPackets : UInt16
    }
    
    var description: String {
        return "index=\(index);total=\(numOfPackets)"
    }
    
    static func encode(string:String,pageSize:Int) -> [QRPageData]? {
        let data2 = string.data(using: .utf8)
        guard let data = data2 else {
            return nil
        }
        print("size:\(data.count)")
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMdd_HH:mm:ss"
        let dateStr = formatter.string(from: Date())
        let fileName = "text_\(dateStr).txt"
        return encode(fileName: fileName, data: data, pageSize: pageSize)
    }
    
    static func encode(file:URL,pageSize:Int) -> [QRPageData]? {
        let data = try! Data.init(contentsOf:file)
        print("filesize:\(data.count)")
        let fileName = file.lastPathComponent
        return encode(fileName: fileName, data: data, pageSize: pageSize)
    }
    
    private static func encode(fileName:String,data:Data,pageSize:Int) -> [QRPageData]? {
        let payloadSize = pageSize - 4;
        let metaLen = fileName.data(using: .utf8)!.count + QRMetaData.encodeHeaderSize()
        let metaPayloadMaxLen = payloadSize - metaLen;
        
        var meta : QRMetaData
        if data.count <= metaPayloadMaxLen {//single page
            meta = QRMetaData(fileName: fileName, fileSize: UInt32(data.count), payload: data)
            return [QRPageData(index: 0, numOfPackets: 1, payload: meta.encode())]
        }else{//multiple pages
            var pages = [QRPageData]()
            meta = QRMetaData(fileName: fileName, fileSize: UInt32(data.count), payload: data.subdata(in: 0 ..< metaPayloadMaxLen))
            let numOfPackets = Int(ceil(Double(data.count - metaPayloadMaxLen) / Double(payloadSize)) + 1)
            pages.append(QRPageData(index: 0, numOfPackets: UInt16(numOfPackets), payload: meta.encode()))
            for i in 0 ..< numOfPackets-1 {
                let payload = data.subdata(in: metaPayloadMaxLen + i*payloadSize ..< min(metaPayloadMaxLen + (i+1)*payloadSize,data.count))
                pages.append(QRPageData(index:UInt16(i + 1),numOfPackets: UInt16(numOfPackets),payload:payload))
            }
            return pages
        }
    }
    
    func encode() -> Data {
        var metaStruct = QRPageMetaData(index: index, numOfPackets: numOfPackets)
        var data = Data()
        let meta = Data.init(bytes: &metaStruct, count: MemoryLayout<QRPageMetaData>.size)
        data.append(meta)
        data.append(payload)
        return data
    }
    
    static func decode(data:Data) -> QRPageData {
        var metaStruct = QRPageMetaData(index: 0, numOfPackets: 0)
        let metaSize = MemoryLayout<QRPageMetaData>.size
        (data as NSData).getBytes(&metaStruct, range: NSMakeRange(0, metaSize))
        let payloads = data.subdata(in: metaSize ..< data.count)
        let page = QRPageData(index: metaStruct.index, numOfPackets: metaStruct.numOfPackets, payload: payloads)
        return page
    }
}

