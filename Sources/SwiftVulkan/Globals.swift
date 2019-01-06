
import CVulkan

public struct Extent3D {
    let width: UInt32
    let height: UInt32
    let depth: UInt32
}

public struct Version {
    let major: Int
    let minor: Int
    let patch: Int

    var rawVersion: UInt32 {
        let val = (major << 22) | (minor << 12) | patch
        return UInt32(val)
    }

    public init(from rawValue: UInt32) {
        let val: Int = Int(rawValue)
        patch = val & 0xFFF
        minor = (val >> 12) & 0x3FF
        major = val >> 22
    }
}
