//
// Created by Alexander Ubillus on 2019-02-04.
//

import Foundation
import CVulkan

public class Fence {

    public let vulkanValue: VkFence

    public init(vulkanValue: VkFence) {
        self.vulkanValue = vulkanValue
    }
}
