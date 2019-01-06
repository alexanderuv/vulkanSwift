
import Foundation
import CVulkan

func convertTupleToString<T>(_ tuple: T) -> String {
    let tupleMirror = Mirror(reflecting: tuple)
    let data = tupleMirror.children.map({ $0.value as! Int8 })
    return String(cString: UnsafePointer(data))
}

func convertTupleToByteArray<T>(_ tuple: T) -> [UInt8] {
    let tupleMirror = Mirror(reflecting: tuple)
    return tupleMirror.children.map({ $0.value as! UInt8 })
}

extension Array where Element == String {
    func asCStringArray() -> UnsafePointer<UnsafePointer<Int8>?> {
        return UnsafePointer(self.map { $0.asCString() })
    }
}

extension String {
    public func asCString() -> UnsafePointer<Int8>? {
        let nsVal = self as NSString
        return nsVal.cString(using: String.Encoding.utf8.rawValue)
    }
}

extension VkResult {
    func toResult() -> Result {
        return Result(rawValue: self.rawValue)!
    }
}

extension Bool {
    func toUInt32() -> UInt32 {
        return self ? 1 : 0
    }
}

extension UInt32 {
    func toBool() -> Bool {
        return self > 0
    }
}
