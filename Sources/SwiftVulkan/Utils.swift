//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

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