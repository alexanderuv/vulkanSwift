//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Device {

    public let instance: Instance
    public let pointer: VkDevice

    init(instance: Instance,
         device: VkDevice) {
        self.instance = instance
        self.pointer = device
    }

    public func createQueue(presentFamilyIndex: UInt32) -> Queue {
        var queueArr = [VkQueue?](repeating: VkQueue(bitPattern: 0), count: 1)
        vkGetDeviceQueue(self.pointer, UInt32(presentFamilyIndex), 0, &queueArr)

        return Queue(fromVulkan: queueArr[0]!)
    }

    public func createCommandPool(createInfo info: CommandPoolCreateInfo) throws -> CommandPool {
        var cCommandPool = VkCommandPool(bitPattern: 0)
        var opResult = VK_SUCCESS

        withUnsafePointer(to: info.toVulkan()) { 
            opResult = vkCreateCommandPool(pointer, $0, nil, &cCommandPool)
        }
    
        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return CommandPool(
                device: self,
                pointer: cCommandPool!
            )
    }

    public func allocateMemory(allocInfo allocateInfo: MemoryAllocateInfo) throws -> DeviceMemory {

        var deviceMemory = VkDeviceMemory(bitPattern: 0)
        let opResult = withUnsafePointer(to: allocateInfo.vulkan) {
            return vkAllocateMemory(self.pointer, $0, nil, &deviceMemory)
        }
        
        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return DeviceMemory(deviceMemory!, device: self)
    }

    public func allocateCommandBuffer(createInfo info: CommandBufferAllocateInfo) throws -> CommandBuffer {
        var output = VkCommandBuffer(bitPattern: 0) // *pOutput = NULL
        var opResult = VK_SUCCESS

        withUnsafePointer(to: info.toVulkan()) { _createInfo in
            let createInfoPtr = _createInfo
            withUnsafeMutablePointer(to: &output) { mut in
                let outputPtr = mut
                opResult = vkAllocateCommandBuffers(self.pointer, createInfoPtr, outputPtr)
            }
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }
        
        return CommandBuffer(pointer: output!)
    }

    public func createSwapchain(createInfo info: SwapchainCreateInfo) throws -> Swapchain {
        var swapchain = VkSwapchainKHR(bitPattern: 0)

        var opResult = VK_SUCCESS
        var infoArr = [info.toVulkan()]

        opResult = vkCreateSwapchainKHR(self.pointer, &infoArr, nil, &swapchain)
        
        if opResult == VK_SUCCESS {
            return Swapchain(device: self, pointer: swapchain!)
        }

        throw opResult.toResult()
    }

    deinit {
        print("Destroying device")
        vkDestroyDevice(pointer, nil)
    }
}