
import CVulkan
import Foundation

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



func vkGetPhysicalDeviceProperties(_ physicalDevice: VkPhysicalDevice) -> VkPhysicalDeviceProperties {
    let cProps = UnsafeMutablePointer<CVulkan.VkPhysicalDeviceProperties>.allocate(capacity: 1)
    defer {
        cProps.deallocate()
    }

    CVulkan.vkGetPhysicalDeviceProperties(physicalDevice.pointer, cProps)
    let prop = cProps.pointee

    return VkPhysicalDeviceProperties(
        prop.apiVersion,
        driverVersion: prop.driverVersion,
        vendorID: Int(prop.vendorID),
        deviceID: Int(prop.deviceID),
        deviceType: VkPhysicalDeviceType(rawValue: Int(prop.deviceType.rawValue))!,
        deviceName: convertTupleToString(prop.deviceName),
        pipelineCacheUUID: convertTupleToByteArray(prop.pipelineCacheUUID)
    )
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