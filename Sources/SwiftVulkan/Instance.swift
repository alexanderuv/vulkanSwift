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
 
    deinit {
        vkDestroyInstance(pointer, nil)
    }
}