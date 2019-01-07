//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class CommandBuffer {

    public let pointer: VkCommandBuffer

    init(pointer: VkCommandBuffer) {
        self.pointer = pointer
    }
}

public class CommandPool {
    private let device: Device
    public let pointer: VkCommandPool

    init(device: Device, pointer: VkCommandPool) {
        self.device = device
        self.pointer = pointer
    }

    deinit {
        vkDestroyCommandPool(device.pointer, pointer, nil)
    }
}