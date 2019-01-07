//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Surface {

    public let instance: Instance
    public let pointer: VkSurfaceKHR

    public init(instance: Instance, surface: VkSurfaceKHR) {
        self.instance = instance
        self.pointer = surface
    }

    deinit {
        vkDestroySurfaceKHR(instance.pointer, pointer, nil)
    }
}