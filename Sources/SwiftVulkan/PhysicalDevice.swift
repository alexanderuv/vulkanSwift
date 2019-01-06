import CVulkan

public class PhysicalDevice {
    private let pointer: VkPhysicalDevice

    init(instance: Instance, vulkanDevice: VkPhysicalDevice) {
        self.pointer = vulkanDevice
    }

    public lazy var properties: PhysicalDeviceProperties = {
        let cProps = UnsafeMutablePointer<VkPhysicalDeviceProperties>.allocate(capacity: 1)
        defer {
            cProps.deallocate()
        }

        vkGetPhysicalDeviceProperties(self.pointer, cProps)
        let prop = cProps.pointee

        return PhysicalDeviceProperties(
            apiVersion: prop.apiVersion,
            driverVersion: prop.driverVersion,
            vendorID: Int(prop.vendorID),
            deviceID: Int(prop.deviceID),
            deviceType: PhysicalDeviceType(rawValue: prop.deviceType.rawValue)!,
            deviceName: convertTupleToString(prop.deviceName),
            pipelineCacheUUID: convertTupleToByteArray(prop.pipelineCacheUUID)
        )
    }()

    public lazy var queueFamilyProperties: [QueueFamilyProperties] = {
        var result: [QueueFamilyProperties] = []
        var count: UInt32 = 0

        withUnsafeMutablePointer(to: &count) {
            vkGetPhysicalDeviceQueueFamilyProperties(self.pointer, $0, nil)
        }
        
        if count > 0 {
            let cProps = UnsafeMutablePointer<VkQueueFamilyProperties>.allocate(capacity: Int(count))
            defer {
                cProps.deallocate()
            }

            withUnsafeMutablePointer(to: &count) {
                vkGetPhysicalDeviceQueueFamilyProperties(self.pointer, $0, cProps)
            }
          
            for i in 0..<Int(count) {
                let cProp = cProps[i]
                let newProp = QueueFamilyProperties(
                    index: UInt32(i),
                    queueFlags: QueueFamilyProperties.Flags(rawValue: cProp.queueFlags),
                    queueCount: cProp.queueCount,
                    timestampValidBits: cProp.timestampValidBits,
                    minImageTransferGranularity: cProp.minImageTransferGranularity.swiftVersion()
                )

                print(newProp)
                result.append(newProp)
            }
        }

        return result
    }()

    public lazy var features: PhysicalDeviceFeatures = {
        let featuresPtr = UnsafeMutablePointer<VkPhysicalDeviceFeatures>.allocate(capacity: 1)
        defer {
            featuresPtr.deallocate()
        }

        vkGetPhysicalDeviceFeatures(self.pointer, featuresPtr)
        let features = featuresPtr.pointee

        return PhysicalDeviceFeatures(
            vkFeatures: features
        )
    }()

    public func getSurfaceFormats(for surface: Surface) -> (Result, [SurfaceFormat]?) {
        
        var returnValue: [SurfaceFormat] = []
        var opResult = VK_SUCCESS

        var count = UInt32(0)
        withUnsafeMutablePointer(to: &count) { countPtr in
            opResult = vkGetPhysicalDeviceSurfaceFormatsKHR(
                self.pointer, surface.pointer, countPtr, nil)    
        }

        if opResult == VK_SUCCESS && count > 0 {
            var cFormats = UnsafeMutablePointer<VkSurfaceFormatKHR>.allocate(capacity: Int(count))
            defer {
                cFormats.deallocate()
            }

            withUnsafeMutablePointer(to: &count) { c in
                let countPtr = c
                opResult = vkGetPhysicalDeviceSurfaceFormatsKHR(
                        self.pointer, surface.pointer, countPtr, cFormats)
            }

            if opResult == VK_SUCCESS && count > 0 {
                for i in 0..<count {
                    let format = cFormats[Int(i)]
                    let newFormat = SurfaceFormat(
                        format: Format(rawValue: format.format.rawValue)!,
                        colorSpace: ColorSpace(rawValue: format.colorSpace.rawValue)!
                    )

                    print(newFormat)
                    returnValue.append(newFormat)
                }
            }
        }
        
        return (opResult.toResult(), returnValue)
    }

    public func hasSurfaceSupport(for family: QueueFamilyProperties, surface: Surface) throws -> Bool {

        var vulkanBool: VkBool32 = 0
        var opResult = VK_SUCCESS
        withUnsafeMutablePointer(to: &vulkanBool) {
            opResult = vkGetPhysicalDeviceSurfaceSupportKHR(self.pointer, family.index, surface.pointer, $0)
        }
        
        if opResult == VK_SUCCESS {
            return vulkanBool > 0
        }

        throw opResult.toResult()
    }

    public func getSurfacePresentModes(surface surf: Surface) -> [PresentMode]? {

        var result: [PresentMode] = []
        var opResult = VK_SUCCESS
        var count = UInt32(0)
        withUnsafeMutablePointer(to: &count) { countPtr in
            opResult = vkGetPhysicalDeviceSurfacePresentModesKHR(
                self.pointer, surf.pointer, countPtr, nil)
        }
        
        if opResult != VK_SUCCESS {
            return nil
        }

        var cPresentModes = UnsafeMutablePointer<VkPresentModeKHR>.allocate(capacity: Int(count))
        defer {
            cPresentModes.deallocate()
        }
        withUnsafeMutablePointer(to: &count) { countPtr in
            opResult = vkGetPhysicalDeviceSurfacePresentModesKHR(
                self.pointer, surf.pointer, countPtr, cPresentModes)
        }

        if opResult != VK_SUCCESS {
            return nil
        }

        for i in 0..<count {
            let presentMode = cPresentModes[Int(i)]
            let newPresentMode = PresentMode(rawValue: presentMode.rawValue)!

            print(newPresentMode)
            result.append(newPresentMode)
        }

        return result
    }

    public func createDevice(createInfo info: DeviceCreateInfo) throws -> Device {
        // let devicePtr = UnsafeMutablePointer<VkDevice?>.allocate(capacity: 1)
        // defer {
        //     devicePtr.deallocate()
        // }

        var device = VkDevice(bitPattern: 0)

        var opResult = VK_SUCCESS
        info.vulkanExec() {
            withUnsafePointer(to: $0) { deviceCreatePtr in
                withUnsafeMutablePointer(to: &device) { devicePtr in
                    opResult = vkCreateDevice(self.pointer, deviceCreatePtr, nil, devicePtr)
                }
            }
        }
        
        if opResult == VK_SUCCESS {
            return Device(device: device!)
        }

        throw opResult.toResult()
    }
}

public class Surface {

    let instance: Instance
    let pointer: VkSurfaceKHR

    public init(instance: Instance, surface: VkSurfaceKHR) {
        self.instance = instance
        self.pointer = surface
    }

    deinit {
        vkDestroySurfaceKHR(instance.pointer, pointer, nil)
    }
}