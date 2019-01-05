
import CVulkan

public class Instance {

    private let createInfo: VkInstanceCreateInfo
    private let instancePointer: VkInstance

    public init(info: VkInstanceCreateInfo) throws {
        self.createInfo = info

        guard let instance = vkCreateInstance(self.createInfo) else {
            throw VulkanError.failure("Unable to create instance")
        }
        self.instancePointer = instance
    }

    public func enumeratePhysicalDevices() -> [PhysicalDevice] {
        let instance = self.instancePointer
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }

        var opResult = CVulkan.vkEnumeratePhysicalDevices(instance.pointer, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [PhysicalDevice] = []
        if (opResult == VK_SUCCESS || opResult == VK_INCOMPLETE) && count > 0 {
            let devicePtr = UnsafeMutablePointer<VkPhysicalDevice?>.allocate(capacity: count)
            defer {
                devicePtr.deallocate()
            }
            opResult = CVulkan.vkEnumeratePhysicalDevices(instance.pointer, countPtr, devicePtr)
            count = Int(countPtr.pointee)

            if opResult == VK_SUCCESS || opResult == VK_INCOMPLETE {
                for i in 0..<count {
                    let cDevicePtr = devicePtr[i]
                    let newProp = PhysicalDevice(vulkanDevice: cDevicePtr!)

                    result.append(newProp)
                    print(newProp)
                }
            }
        } else {
            // throw error here
        }

        return result
    }
 
    deinit {
        vkDestroyInstance(self.instancePointer)
    }
}

public enum VulkanError: Error {
    case failure(_ msg: String)
}


public class VkApplicationInfo {
    static let sType = VkStructureType.applicationInfo

    // not supported for now
    let next: Any? = nil

    let applicationName: String
    let applicationVersion: UInt32
    let engineName: String
    let engineVersion: UInt32
    let apiVersion: UInt32

    public init(_ applicationName: String, 
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

public class VkInstanceCreateInfo {
    static let sType = VkStructureType.instanceCreateInfo
    let next: Any? = nil
    let flags = 0

    let applicationInfo: VkApplicationInfo?
    let enabledLayerNames: [String]
    let enabledExtensionNames: [String]

    public init(applicationInfo: VkApplicationInfo?,
        enabledLayerNames: [String],
        enabledExtensionNames: [String]) {
        self.applicationInfo = applicationInfo
        self.enabledLayerNames = enabledLayerNames
        self.enabledExtensionNames = enabledExtensionNames
    }
}

fileprivate class VkInstance {
    let pointer: OpaquePointer

    init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }
}

fileprivate func vkCreateInstance(_ createInfo: VkInstanceCreateInfo) -> VkInstance? {

    let arrEnabledLayerNames = createInfo.enabledLayerNames.map { $0.asCString() }
    let enabledLayerNamesPtr = UnsafePointer(arrEnabledLayerNames)

    let arrEnabledExtensionNames = createInfo.enabledExtensionNames.map { $0.asCString() }
    let enabledExtensionNamesPtr = UnsafePointer(arrEnabledExtensionNames)

    let cCreateInfo = CVulkan.VkInstanceCreateInfo(
        sType: CVulkan.VkStructureType(rawValue: VkInstanceCreateInfo.sType.rawValue),
        pNext: nil,
        flags: 0,
        pApplicationInfo: nil, // &appInfo,
        enabledLayerCount: UInt32(createInfo.enabledLayerNames.count),
        ppEnabledLayerNames: enabledLayerNamesPtr,
        enabledExtensionCount: UInt32(createInfo.enabledExtensionNames.count),
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

fileprivate func vkDestroyInstance(_ instance: VkInstance) {
    CVulkan.vkDestroyInstance(instance.pointer, nil)
}
