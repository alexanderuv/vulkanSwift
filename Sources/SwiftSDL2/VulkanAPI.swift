// Swift-bindings for VulkanAPI
import CVulkan

func convertTupleToString<T>(_ tuple: T) -> String {
    let tupleMirror = Mirror(reflecting: tuple)
    let data = tupleMirror.children.map({ $0.value as! Int8 })
    return String(cString: UnsafePointer(data))
    // withUnsafePointer(to: data) { ptr: UnsafePointer<Int8> in
    //     result = String(cString: ptr)
    // }

    // return result
}

public class VulkanAPI {

    public struct Version {
        let major: Int
        let minor: Int
        let patch: Int

        var rawVersion: UInt32 {
            let val = (major << 22) | (minor << 12) | patch
            return UInt32(val)
        }
    }

    public struct VkApplicationInfo {
        static let sType = VK_STRUCTURE_TYPE_APPLICATION_INFO

        // not supported for now
        //let next: Any

        let applicationName: String
        let applicationVersion: UInt32
        let engineName: String
        let engineVersion: UInt32
        let apiVersion: UInt32
    }

    public struct VkInstanceCreateInfo {
        static let sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO

        // not supported for now
        //let next: Any

        // reserved for future use
        //let flags = 0

        let applicationInfo: VkApplicationInfo
    }

    public struct VkExtensionProperties {
        let extensionName: String
        let specVersion: UInt32
    }

    public struct VkLayerProperties {
        let layerName: String
        let specVersion: UInt32
        let implementationVersion: UInt32
        let description: String
    }

    public class func vkCreateInstance(_ createInfo: VkInstanceCreateInfo) -> VkInstance? {
        return nil
    }

    public class func vkEnumerateInstanceExtensionProperties(_ layerName: String?) -> [VkExtensionProperties] {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }

        var opResult = CVulkan.vkEnumerateInstanceExtensionProperties(layerName, countPtr, nil)
        var count = Int(countPtr.pointee)

        print("\(count) extension properties were found")
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
                        specVersion: cProp.specVersion
                    )

                    print(newProp)
                }
            }
        } else {
            // throw error here
        }

        return []
    }

    public class func vkEnumerateInstanceLayerProperties() -> [VkLayerProperties] {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }
        
        var opResult = CVulkan.vkEnumerateInstanceLayerProperties(countPtr, nil)
        var count = Int(countPtr.pointee)

        print("\(count) layer properties were found")
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
                        specVersion: cProp.specVersion,
                        implementationVersion: cProp.implementationVersion,
                        description: convertTupleToString(cProp.description)
                    )

                    print(newProp)
                }
            }
        }

        return []
    }
}

