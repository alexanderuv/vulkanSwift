//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

// This is not a Vulkan struct, but we're adding it to improve semantics
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
