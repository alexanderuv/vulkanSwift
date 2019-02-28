//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class SurfaceKHR {

    public let instance: Instance
    public let vulkanPointer: VkSurfaceKHR

    public init(instance: Instance, surface: VkSurfaceKHR) {
        self.instance = instance
        self.vulkanPointer = surface
    }

    deinit {
        print("Destroying surface")
        vkDestroySurfaceKHR(instance.pointer, vulkanPointer, nil)
    }
}
