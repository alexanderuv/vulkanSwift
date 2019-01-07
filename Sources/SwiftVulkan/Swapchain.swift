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

    deinit {
        vkDestroySwapchainKHR(device.pointer, self.pointer, nil)
    }
}