//
// Created by Alexander Ubillus on 2019-02-04.
//

import Foundation
import CVulkan

public class Semaphore {
    public let vulkanValue: VkSemaphore
    public let device: Device

    public init(vulkanValue: VkSemaphore, device: Device) {
        self.vulkanValue = vulkanValue
        self.device = device
    }

    public class func create(info: SemaphoreCreateInfo, device: Device) throws -> Semaphore {
        var semaphore = VkSemaphore(bitPattern: 0)
        let opResult = withUnsafePointer(to: info.vulkanValue) {
            return vkCreateSemaphore(device.pointer, $0, nil, &semaphore)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return Semaphore(vulkanValue: semaphore!, device: device)
    }
    
    deinit {
        vkDestroySemaphore(self.device.pointer, self.vulkanValue, nil)
    }
}
