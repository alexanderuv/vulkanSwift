//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Instance {

    public let pointer: VkInstance

    init(rawInstance: VkInstance) {
        self.pointer = rawInstance
    }

    public class func createInstance(createInfo info: InstanceCreateInfo) throws -> Instance {
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

        var instancePtr = VkInstance(bitPattern: 0)
        var opResult = VK_ERROR_INITIALIZATION_FAILED
        withUnsafePointer(to: cCreateInfo) {
            opResult = vkCreateInstance($0, nil, &instancePtr)
        }

        // let function = vkGetInstanceProcAddr(instancePtr!, "vkCreateDebugReportCallbackEXT")
        // let vkCreateDebugReportCallbackEXT = 
        //     unsafeBitCast(function, to: PFN_vkCreateDebugReportCallbackEXT.self)

        // var infoArr = [VkDebugReportCallbackCreateInfoEXT(
        //     sType: VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT,
        //     pNext: nil,
        //     flags: VK_DEBUG_REPORT_INFORMATION_BIT_EXT.rawValue | 
        //     VK_DEBUG_REPORT_WARNING_BIT_EXT.rawValue | 
        //     VK_DEBUG_REPORT_ERROR_BIT_EXT.rawValue | 
        //     VK_DEBUG_REPORT_DEBUG_BIT_EXT.rawValue,
        //     pfnCallback: { (flags: VkDebugReportFlagsEXT, 
        //                     objectType: VkDebugReportObjectTypeEXT,
        //                     object: UInt64,
        //                     location: Int,
        //                     messageCode: Int32,
        //                     pLayerPrefix: UnsafePointer<Int8>?,
        //                     pMessage: UnsafePointer<Int8>?,
        //                     pUserData: UnsafeMutableRawPointer?) in
        //         print("[\(objectType.rawValue)] message: \(String(cString: pMessage!))")
        //         return 0
        //     },
        //     pUserData: nil
        // )]

        // var callback = VkDebugReportCallbackEXT(bitPattern: 0)
        // opResult = vkCreateDebugReportCallbackEXT(instancePtr!, &infoArr, nil, &callback)

        if opResult == VK_SUCCESS {
            return Instance(rawInstance: instancePtr!)
        }
        
        throw opResult.toResult()
    }

    public func createSurface(createInfo info: SurfaceCreateInfo) throws -> Surface {
        var surface = VkSurfaceKHR(bitPattern: 0)

        var opResult = VK_SUCCESS
        withUnsafePointer(to: info.toVulkan()) {
            opResult = vkCreateMacOSSurfaceMVK(self.pointer, $0, nil, &surface)
        }

        if opResult == VK_SUCCESS {
            return Surface(instance: self,  surface: surface!)
        }
        
        throw opResult.toResult()
    }

    public func enumeratePhysicalDevices() throws -> [PhysicalDevice] {
        var count: UInt32 = 0
        var result: [PhysicalDevice] = []
        var opResult = VK_SUCCESS

        withUnsafeMutablePointer(to: &count) {
            opResult = vkEnumeratePhysicalDevices(self.pointer, $0, nil)    
        }

        if opResult != VK_SUCCESS {
            throw opResult.toResult()
        }

        if count > 0 {
            var devices = [VkPhysicalDevice?](repeating: VkPhysicalDevice(bitPattern: 0), count: Int(count))
            
            withUnsafeMutablePointer(to: &count) {
                opResult = vkEnumeratePhysicalDevices(self.pointer, $0, &devices)
            }

            if opResult != VK_SUCCESS {
                throw opResult.toResult()
            }

            for device in devices {
                let item = PhysicalDevice(instance: self, vulkanDevice: device!)
                result.append(item)
            }
        }

        return result
    }


    public class func enumerateExtensionProperties(_ layerName: String?) throws -> [ExtensionProperties] {
        var countArr: [UInt32] = [0]
        var opResult = vkEnumerateInstanceExtensionProperties(layerName, &countArr, nil)
        if opResult != VK_SUCCESS {
            throw opResult.toResult()
        }

        let count = Int(countArr[0])
        var result: [ExtensionProperties] = []
        if count > 0 {
            var props = [VkExtensionProperties](repeating: VkExtensionProperties(), count: count)
            opResult = vkEnumerateInstanceExtensionProperties(layerName, &countArr, &props)

            if opResult != VK_SUCCESS {
                throw opResult.toResult()
            }

            for cProp in props {
                let newProp = ExtensionProperties(props: cProp)
                result.append(newProp)
            }
        }

        return result
    }

    public class func enumerateLayerProperties() throws -> [LayerProperties] {
        var countArr: [UInt32] = [0]
        var opResult = vkEnumerateInstanceLayerProperties(&countArr, nil)

        if opResult != VK_SUCCESS {
            throw opResult.toResult()
        }

        let count = Int(countArr[0])
        var result: [LayerProperties] = []
        if count > 0 {
            var props = [VkLayerProperties](repeating: VkLayerProperties(), count: count)
            opResult = vkEnumerateInstanceLayerProperties(&countArr, &props)

            if opResult != VK_SUCCESS {
                throw opResult.toResult()
            }

            for cProp in props {
                let newProp = LayerProperties(
                        layerName: convertTupleToString(cProp.layerName),
                        specVersion: Version(from: cProp.specVersion),
                        implementationVersion: Version(from: cProp.implementationVersion),
                        description: convertTupleToString(cProp.description)
                )

                result.append(newProp)
            }
        }

        return result
    }
 
    deinit {
        print("Destroying instance")
        vkDestroyInstance(pointer, nil)
    }
}