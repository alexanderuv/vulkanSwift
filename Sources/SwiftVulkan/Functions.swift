import CVulkan
import Foundation

public struct ExtensionProperties {
    let extensionName: String
    let specVersion: Version
}

public struct LayerProperties {
    let layerName: String
    let specVersion: UInt32
    let implementationVersion: UInt32
    let description: String

    fileprivate init(layerName: String,
        specVersion: Version,
        implementationVersion: Version,
        description: String) {
        self.layerName = layerName
        self.specVersion = specVersion.rawVersion
        self.implementationVersion = implementationVersion.rawVersion
        self.description = description
    }
}

public func enumerateInstanceExtensionProperties(_ layerName: String?) -> [ExtensionProperties] {
    let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    countPtr.initialize(to: 0)
    defer {
        countPtr.deallocate()
    }

    var opResult = vkEnumerateInstanceExtensionProperties(layerName, countPtr, nil)
    var count = Int(countPtr.pointee)

    var result: [ExtensionProperties] = []
    if (opResult == VK_SUCCESS || opResult == VK_INCOMPLETE) && count > 0 {
        let cProps = UnsafeMutablePointer<VkExtensionProperties>.allocate(capacity: count)
        defer {
            cProps.deallocate()
        }
        opResult = vkEnumerateInstanceExtensionProperties(layerName, countPtr, cProps)
        count = Int(countPtr.pointee)

        if opResult == VK_SUCCESS || opResult == VK_INCOMPLETE {
            for i in 0..<count {
                let cProp = cProps[i]
                let newProp = ExtensionProperties(
                    extensionName: convertTupleToString(cProp.extensionName),
                    specVersion: Version(from: cProp.specVersion)
                )

                result.append(newProp)
                print(newProp)
            }
        }
    } else {
        // throw error here
    }

    return result
}

public func enumerateInstanceLayerProperties() -> [LayerProperties] {
    let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    countPtr.initialize(to: 0)
    defer {
        countPtr.deallocate()
    }
    
    var opResult = vkEnumerateInstanceLayerProperties(countPtr, nil)
    var count = Int(countPtr.pointee)

    var result: [LayerProperties] = []
    if opResult == VK_SUCCESS && count > 0 {
        let cProps = UnsafeMutablePointer<VkLayerProperties>.allocate(capacity: count)
        defer {
            cProps.deallocate()
        }
        opResult = vkEnumerateInstanceLayerProperties(countPtr, cProps)
        count = Int(countPtr.pointee)
        if opResult == VK_SUCCESS {
            for i in 0..<count {
                let cProp = cProps[i]
                let newProp = LayerProperties(
                    layerName: convertTupleToString(cProp.layerName),
                    specVersion: Version(from: cProp.specVersion),
                    implementationVersion: Version(from: cProp.implementationVersion),
                    description: convertTupleToString(cProp.description)
                )

                print(newProp)
                result.append(newProp)
            }
        }
    }

    return result
}