
import CVulkan

public class Instance {

    private let createInfo: VkInstanceCreateInfo
    private let instancePointer: VkInstance

    init(createInfo: VkInstanceCreateInfo) throws {
        self.createInfo = createInfo

        guard let instance = vkCreateInstance(self.createInfo) else {
            throw VulkanError.failure("Unable to create instance")
        }
        self.instancePointer = instance
    }

    public func enumeratePhysicalDevices() -> [VkPhysicalDevice] {
        let instance = self.instancePointer
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
 
    deinit {
        vkDestroyInstance(self.instancePointer)
    }
}

public enum VulkanError: Error {
    case failure(_ msg: String)
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
