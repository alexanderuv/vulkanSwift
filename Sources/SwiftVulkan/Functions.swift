import CVulkan
import Foundation

public class VkExtensionProperties {
    let extensionName: String
    let specVersion: UInt32

    fileprivate init(extensionName: String,
        specVersion: Version) {
        self.extensionName = extensionName
        self.specVersion = specVersion.rawVersion
    }
}

public struct VkLayerProperties {
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

public func vkEnumerateInstanceExtensionProperties(_ layerName: String?) -> [VkExtensionProperties] {
    let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    countPtr.initialize(to: 0)
    defer {
        countPtr.deallocate()
    }

    var opResult = CVulkan.vkEnumerateInstanceExtensionProperties(layerName, countPtr, nil)
    var count = Int(countPtr.pointee)

    var result: [VkExtensionProperties] = []
    if (opResult == VK_SUCCESS || opResult == VK_INCOMPLETE) && count > 0 {
        let cProps = UnsafeMutablePointer<CVulkan.VkExtensionProperties>.allocate(capacity: count)
        defer {
            cProps.deallocate()
        }
        opResult = CVulkan.vkEnumerateInstanceExtensionProperties(layerName, countPtr, cProps)
        count = Int(countPtr.pointee)

        if opResult == VK_SUCCESS || opResult == VK_INCOMPLETE {
            for i in 0..<count {
                let cProp = cProps[i]
                let newProp = VkExtensionProperties(
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

public func vkEnumerateInstanceLayerProperties() -> [VkLayerProperties] {
    let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
    countPtr.initialize(to: 0)
    defer {
        countPtr.deallocate()
    }
    
    var opResult = CVulkan.vkEnumerateInstanceLayerProperties(countPtr, nil)
    var count = Int(countPtr.pointee)

    var result: [VkLayerProperties] = []
    if opResult == VK_SUCCESS && count > 0 {
        let cProps = UnsafeMutablePointer<CVulkan.VkLayerProperties>.allocate(capacity: count)
        defer {
            cProps.deallocate()
        }
        opResult = CVulkan.vkEnumerateInstanceLayerProperties(countPtr, cProps)
        count = Int(countPtr.pointee)
        if opResult == VK_SUCCESS {
            for i in 0..<count {
                let cProp = cProps[i]
                let newProp = VkLayerProperties(
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

protocol ReflectedStringConvertible : CustomStringConvertible { }

extension ReflectedStringConvertible {
  public var description: String {
    let mirror = Mirror(reflecting: self)
    
    var str = "\(mirror.subjectType)("
    var first = true
    for (label, value) in mirror.children {
      if let label = label {
        if first {
          first = false
        } else {
          str += ", "
        }
        str += label
        str += ": "
        str += "\(value)"
      }
    }
    str += ")"
    
    return str
  }
}