//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan
import Foundation

public func enumerateInstanceExtensionProperties(_ layerName: String?) throws -> [ExtensionProperties] {
    var countArr: [UInt32] = [0]
    var opResult = vkEnumerateInstanceExtensionProperties(layerName, &countArr, nil)
    if opResult != VK_SUCCESS {
        throw opResult.toResult()
    }

    let count = Int(countArr[0])
    var result: [ExtensionProperties] = []
    if count > 0 {
        var props = [VkExtensionProperties](repeating: VkExtensionProperties(), count: count)
        opResult = vkEnumerateInstanceExtensionProperties(layerName, &countArr, &props)

        if opResult != VK_SUCCESS {
            throw opResult.toResult()
        }

        for cProp in props {
            let newProp = ExtensionProperties(props: cProp)
            result.append(newProp)
        }  
    } 

    return result
}

public func enumerateInstanceLayerProperties() throws -> [LayerProperties] {
    var countArr: [UInt32] = [0]
    var opResult = vkEnumerateInstanceLayerProperties(&countArr, nil)

    if opResult != VK_SUCCESS {
        throw opResult.toResult()
    }

    let count = Int(countArr[0])
    var result: [LayerProperties] = []
    if count > 0 {
        var props = [VkLayerProperties](repeating: VkLayerProperties(), count: count)
        opResult = vkEnumerateInstanceLayerProperties(&countArr, &props)
        
        if opResult != VK_SUCCESS {
            throw opResult.toResult()
        }

        for cProp in props {
            let newProp = LayerProperties(
                layerName: convertTupleToString(cProp.layerName),
                specVersion: Version(from: cProp.specVersion),
                implementationVersion: Version(from: cProp.implementationVersion),
                description: convertTupleToString(cProp.description)
            )

            result.append(newProp)
        }
    }

    return result
}