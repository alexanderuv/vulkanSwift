// Swift-bindings for VulkanAPI

import CVulkan
import Foundation

fileprivate func convertTupleToString<T>(_ tuple: T) -> String {
    let tupleMirror = Mirror(reflecting: tuple)
    let data = tupleMirror.children.map({ $0.value as! Int8 })
    return String(cString: UnsafePointer(data))
}

fileprivate func convertTupleToByteArray<T>(_ tuple: T) -> [UInt8] {
    let tupleMirror = Mirror(reflecting: tuple)
    return tupleMirror.children.map({ $0.value as! UInt8 })
    //return String(cString: UnsafePointer(data))
}

extension String {
    public func asCString() -> UnsafePointer<Int8>? {
        let nsVal = self as NSString
        return nsVal.cString(using: String.Encoding.utf8.rawValue)
    }
}

extension Int {
    public func toUInt32() -> UInt32 {
        return UInt32(self)
    }
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

    public class VkApplicationInfo {
        let sType = VK_STRUCTURE_TYPE_APPLICATION_INFO

        // not supported for now
        let next: Any?

        let applicationName: String
        let applicationVersion: UInt32
        let engineName: String
        let engineVersion: UInt32
        let apiVersion: UInt32

        init(_ applicationName: String, 
            applicationVersion: Version, 
            engineName: String,
            engineVersion: Version,
            apiVersion: Version) {
            self.applicationName = applicationName
            self.applicationVersion = applicationVersion.rawVersion
            self.engineName = engineName
            self.engineVersion = engineVersion.rawVersion
            self.apiVersion = apiVersion.rawVersion
            self.next = nil
        }
    }

    public struct VkInstanceCreateInfo {
        static let sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO

        // not supported for now
        //let next: Any

        // reserved for future use
        //let flags = 0

        let applicationInfo: VkApplicationInfo?
        let enabledLayerCount: Int
        let enabledLayerNames: [String]
        let enabledExtensionCount: Int
        let enabledExtensionNames: [String]
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

    public class VkInstance {
        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }

    public class VkPhysicalDevice {
        fileprivate let ptr: OpaquePointer

        init(_ ptr: OpaquePointer) {
            self.ptr = ptr
        }
    }

    public class VkSurfaceKHR {
        let pointer: OpaquePointer

        init(_ pointer: OpaquePointer) {
            self.pointer = pointer
        }
    }

    public class VkPhysicalDeviceProperties: ReflectedStringConvertible {
        let apiVersion: UInt32
        let driverVersion: UInt32
        let vendorID: Int
        let deviceID: Int
        let deviceType: VkPhysicalDeviceType
        let deviceName: String
        let pipelineCacheUUID: [UInt8]
        let limits: Any? = nil // TODO: add later if needed
        let sparseProperties: Any? = nil // TODO: add later if needed

        init(
            _ apiVersion: UInt32,
            driverVersion: UInt32,
            vendorID: Int,
            deviceID: Int,
            deviceType: VkPhysicalDeviceType,
            deviceName: String,
            pipelineCacheUUID: [UInt8]) {
            self.apiVersion = apiVersion
            self.driverVersion = driverVersion
            self.vendorID = vendorID
            self.deviceID = deviceID
            self.deviceType = deviceType
            self.deviceName = deviceName
            self.pipelineCacheUUID = pipelineCacheUUID
        }
    }

    public class func vkCreateInstance(_ createInfo: VkInstanceCreateInfo) -> VkInstance? {

        let arrEnabledLayerNames = createInfo.enabledLayerNames.map { $0.asCString() }
        let enabledLayerNamesPtr = UnsafePointer(arrEnabledLayerNames)

        let arrEnabledExtensionNames = createInfo.enabledExtensionNames.map { $0.asCString() }
        let enabledExtensionNamesPtr = UnsafePointer(arrEnabledExtensionNames)

        let cCreateInfo = CVulkan.VkInstanceCreateInfo(
            sType: VkInstanceCreateInfo.sType,
            pNext: nil,
            flags: 0,
            pApplicationInfo: nil, // &appInfo,
            enabledLayerCount: UInt32(createInfo.enabledLayerCount),
            ppEnabledLayerNames: enabledLayerNamesPtr,
            enabledExtensionCount: UInt32(createInfo.enabledExtensionCount),
            ppEnabledExtensionNames: enabledExtensionNamesPtr
        )

        let instancePtr = UnsafeMutablePointer<CVulkan.VkInstance?>.allocate(capacity: 1)
        var opResult = VK_ERROR_INITIALIZATION_FAILED
        withUnsafePointer(to: cCreateInfo) {
            opResult = CVulkan.vkCreateInstance($0, nil, instancePtr)
        }

        if opResult == VK_SUCCESS {
            return VkInstance(instancePtr.pointee!)
        }
        
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
                        specVersion: cProp.specVersion
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

    public class func vkEnumerateInstanceLayerProperties() -> [VkLayerProperties] {
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
                        specVersion: cProp.specVersion,
                        implementationVersion: cProp.implementationVersion,
                        description: convertTupleToString(cProp.description)
                    )

                    print(newProp)
                    result.append(newProp)
                }
            }
        }

        return result
    }

    public class func vkEnumeratePhysicalDevices(_ instance: VkInstance) -> [VkPhysicalDevice] {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }

        var opResult = CVulkan.vkEnumeratePhysicalDevices(instance.pointer, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [VkPhysicalDevice] = []
        if (opResult == VK_SUCCESS || opResult == VK_INCOMPLETE) && count > 0 {
            let devicePtr = UnsafeMutablePointer<CVulkan.VkPhysicalDevice?>.allocate(capacity: count)
            defer {
                devicePtr.deallocate()
            }
            opResult = CVulkan.vkEnumeratePhysicalDevices(instance.pointer, countPtr, devicePtr)
            count = Int(countPtr.pointee)

            if opResult == VK_SUCCESS || opResult == VK_INCOMPLETE {
                for i in 0..<count {
                    let cDevicePtr = devicePtr[i]
                    let newProp = VkPhysicalDevice(cDevicePtr!)

                    result.append(newProp)
                    print(newProp)
                }
            }
        } else {
            // throw error here
        }

        return result
    }

    public class func vkGetPhysicalDeviceProperties(_ physicalDevice: VkPhysicalDevice) -> VkPhysicalDeviceProperties {
        let cProps = UnsafeMutablePointer<CVulkan.VkPhysicalDeviceProperties>.allocate(capacity: 1)
        defer {
            cProps.deallocate()
        }

        CVulkan.vkGetPhysicalDeviceProperties(physicalDevice.ptr, cProps)
        let prop = cProps.pointee

        return VkPhysicalDeviceProperties(
            prop.apiVersion,
            driverVersion: prop.driverVersion,
            vendorID: Int(prop.vendorID),
            deviceID: Int(prop.deviceID),
            deviceType: prop.deviceType,
            deviceName: convertTupleToString(prop.deviceName),
            pipelineCacheUUID: convertTupleToByteArray(prop.pipelineCacheUUID)
        )
    }
}

public protocol ReflectedStringConvertible : CustomStringConvertible { }

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