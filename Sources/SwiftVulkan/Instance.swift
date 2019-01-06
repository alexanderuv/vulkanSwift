
import CVulkan

public struct ApplicationInfo {
    // not supported for now
    public let next: Any? = nil
    public let applicationName: String
    public let applicationVersion: UInt32
    public let engineName: String
    public let engineVersion: UInt32
    public let apiVersion: UInt32

    public init(applicationName: String, 
        applicationVersion: Version, 
        engineName: String,
        engineVersion: Version,
        apiVersion: Version) {
        self.applicationName = applicationName
        self.applicationVersion = applicationVersion.rawVersion
        self.engineName = engineName
        self.engineVersion = engineVersion.rawVersion
        self.apiVersion = apiVersion.rawVersion
    }
}

public struct InstanceCreateInfo {
    public let next: Any? = nil
    public let flags = 0
    public let applicationInfo: ApplicationInfo?
    public let enabledLayerNames: [String]
    public let enabledExtensionNames: [String]

    public init(applicationInfo: ApplicationInfo?,
        enabledLayerNames: [String],
        enabledExtensionNames: [String]) {
        self.applicationInfo = applicationInfo
        self.enabledLayerNames = enabledLayerNames
        self.enabledExtensionNames = enabledExtensionNames
    }
}

public class Instance {

    private let instance: VkInstance

    init(instance: VkInstance) {
        self.instance = instance
    }

    public class func createInstance(createInfo info: InstanceCreateInfo) -> (Result, Instance?) {
        let arrEnabledLayerNames = info.enabledLayerNames.map { $0.asCString() }
        let enabledLayerNamesPtr = UnsafePointer(arrEnabledLayerNames)

        let arrEnabledExtensionNames = info.enabledExtensionNames.map { $0.asCString() }
        let enabledExtensionNamesPtr = UnsafePointer(arrEnabledExtensionNames)

        let cCreateInfo = VkInstanceCreateInfo(
            sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            pNext: nil,
            flags: 0,
            pApplicationInfo: nil, // &appInfo,
            enabledLayerCount: UInt32(info.enabledLayerNames.count),
            ppEnabledLayerNames: enabledLayerNamesPtr,
            enabledExtensionCount: UInt32(info.enabledExtensionNames.count),
            ppEnabledExtensionNames: enabledExtensionNamesPtr
        )

        let instancePtr = UnsafeMutablePointer<VkInstance?>.allocate(capacity: 1)
        var opResult = VK_ERROR_INITIALIZATION_FAILED
        withUnsafePointer(to: cCreateInfo) {
            opResult = vkCreateInstance($0, nil, instancePtr)
        }

        if opResult == VK_SUCCESS {
            return (opResult.toResult(), Instance(instance: instancePtr.pointee!))
        }
        
        return (opResult.toResult(), nil)
    }

    public func enumeratePhysicalDevices() -> [PhysicalDevice] {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }

        var opResult = vkEnumeratePhysicalDevices(instance, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [PhysicalDevice] = []
        if (opResult == VK_SUCCESS || opResult == VK_INCOMPLETE) && count > 0 {
            let devicePtr = UnsafeMutablePointer<VkPhysicalDevice?>.allocate(capacity: count)
            defer {
                devicePtr.deallocate()
            }
            opResult = vkEnumeratePhysicalDevices(instance, countPtr, devicePtr)
            count = Int(countPtr.pointee)

            if opResult == VK_SUCCESS || opResult == VK_INCOMPLETE {
                for i in 0..<count {
                    let cDevicePtr = devicePtr[i]
                    let newProp = PhysicalDevice(vulkanDevice: cDevicePtr!)

                    result.append(newProp)
                }
            }
        } else {
            // throw error here
        }

        return result
    }
 
    deinit {
        vkDestroyInstance(instance, nil)
    }
}

public enum VulkanError: Error {
    case failure(_ msg: String)
}