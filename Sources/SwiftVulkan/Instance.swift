
import CVulkan

public class Instance {

    public let pointer: VkInstance

    init(rawInstance: VkInstance) {
        self.pointer = rawInstance
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
            return (opResult.toResult(), Instance(rawInstance: instancePtr.pointee!))
        }
        
        return (opResult.toResult(), nil)
    }

    public func createSurface(createInfo info: SurfaceCreateInfo) -> (Result, Surface?) {
        let surfacePtr = UnsafeMutablePointer<VkSurfaceKHR?>.allocate(capacity: 1)

        var opResult = VK_SUCCESS
        withUnsafePointer(to: info.toVulkan()) {
            opResult = vkCreateMacOSSurfaceMVK(self.pointer, $0, nil, surfacePtr)
        }

        if opResult == VK_SUCCESS {
            return (opResult.toResult(), Surface(instance: self,  surface: surfacePtr.pointee!))
        }
        
        return (opResult.toResult(), nil)
    }

    public func enumeratePhysicalDevices() -> [PhysicalDevice] {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }

        var opResult = vkEnumeratePhysicalDevices(self.pointer, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [PhysicalDevice] = []
        if (opResult == VK_SUCCESS || opResult == VK_INCOMPLETE) && count > 0 {
            let devicePtr = UnsafeMutablePointer<VkPhysicalDevice?>.allocate(capacity: count)
            defer {
                devicePtr.deallocate()
            }
            opResult = vkEnumeratePhysicalDevices(self.pointer, countPtr, devicePtr)
            count = Int(countPtr.pointee)

            if opResult == VK_SUCCESS || opResult == VK_INCOMPLETE {
                for i in 0..<count {
                    let cDevicePtr = devicePtr[i]
                    let newProp = PhysicalDevice(instance: self, vulkanDevice: cDevicePtr!)

                    result.append(newProp)
                }
            }
        } else {
            // throw error here
        }

        return result
    }
 
    deinit {
        vkDestroyInstance(pointer, nil)
    }
}