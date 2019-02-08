//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Swapchain {
    public let pointer: VkSwapchainKHR
    public let device: Device

    private let surface: Surface

    public init(device: Device, pointer: VkSwapchainKHR, surface: Surface) {
        self.pointer = pointer
        self.device = device
        self.surface = surface
    }

    public class func create(inDevice: Device, createInfo: SwapchainCreateInfo) throws -> Swapchain {
        var swapchain = VkSwapchainKHR(bitPattern: 0)

        var opResult = VK_SUCCESS
        var infoArr = [createInfo.toVulkan()]

        opResult = vkCreateSwapchainKHR(inDevice.pointer, &infoArr, nil, &swapchain)

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return Swapchain(device: inDevice, pointer: swapchain!, surface: createInfo.surface)
    }

    public func acquireNextImage(timeout: UInt64, semaphore: Semaphore?,
                                 fence: Fence?, imageIndex: UInt32) throws {
        var localImageIndex = imageIndex
        let opResult = vkAcquireNextImageKHR(
                self.device.pointer, self.pointer, timeout,
                semaphore?.vulkanValue, fence?.vulkanValue, &localImageIndex)

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }
    }

    public func getSwapchainImages() throws -> [Image] {
        var countArr: [UInt32] = [0]
        var opResult = vkGetSwapchainImagesKHR(self.device.pointer, self.pointer, &countArr, nil)

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        var images = [VkImage?](repeating: VkImage(bitPattern: 0), count: Int(countArr[0]))
        opResult = vkGetSwapchainImagesKHR(self.device.pointer, self.pointer, &countArr, &images)

        return images.map { Image(fromVulkan: $0!, device: self.device, swapchain: self) }
    }

    deinit {
        print("Destroying swapchain")
        vkDestroySwapchainKHR(device.pointer, self.pointer, nil)
    }
}