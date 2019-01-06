
import CVulkan
import Foundation

extension VkExtent3D {
    func swiftVersion() -> Extent3D {
        return Extent3D(
            width: self.width,
            height: self.height,
            depth: self.depth
        )
    }
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