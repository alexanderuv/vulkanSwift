
import Foundation

func convertTupleToString<T>(_ tuple: T) -> String {
    let tupleMirror = Mirror(reflecting: tuple)
    let data = tupleMirror.children.map({ $0.value as! Int8 })
    return String(cString: UnsafePointer(data))
}

func convertTupleToByteArray<T>(_ tuple: T) -> [UInt8] {
    let tupleMirror = Mirror(reflecting: tuple)
    return tupleMirror.children.map({ $0.value as! UInt8 })
}

extension String {
    public func asCString() -> UnsafePointer<Int8>? {
        let nsVal = self as NSString
        return nsVal.cString(using: String.Encoding.utf8.rawValue)
    }
}

extension Int {
    public func toUInt32() -> UInt32 {
        return UInt32(self)
    }
}