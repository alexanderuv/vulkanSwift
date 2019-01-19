//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Swapchain {
    public let pointer: VkSwapchainKHR
    public let device: Device

    public init(device: Device, pointer: VkSwapchainKHR) {
        self.pointer = pointer
        self.device = device
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