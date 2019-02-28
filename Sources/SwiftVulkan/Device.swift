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

    public func allocateDescriptorSets(allocateInfo info: DescriptorSetAllocateInfo) throws -> DescriptorSet {
        var descriptor = VkDescriptorSet(bitPattern: 0)

        let layouts: [VkDescriptorSetLayout?] = info.setLayouts.map { $0.vulkanValue }
        let ai = VkDescriptorSetAllocateInfo(
            sType: VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO, 
            pNext: nil, 
            descriptorPool: info.descriptorPool.vulkanValue, 
            descriptorSetCount: info.descriptorSetCount, 
            pSetLayouts: UnsafePointer(layouts)
        )

        let opResult = withUnsafePointer(to: ai) {
            return vkAllocateDescriptorSets(self.pointer, $0, &descriptor)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return DescriptorSet(vulkanValue: descriptor!, device: self)
    }

    public func updateDescriptorSets(
        descriptorWrites: [WriteDescriptorSet], 
        descriptorCopies: [CopyDescriptorSet]
    ) {
        let writes = descriptorWrites.map { $0.toVulkan() }
        let copies = descriptorCopies.map { $0.toVulkan() }

        vkUpdateDescriptorSets(self.pointer, 
            UInt32(descriptorWrites.count), descriptorWrites.count == 0 ? nil : writes,
            UInt32(descriptorCopies.count), descriptorCopies.count == 0 ? nil : copies)
    }

    deinit {
        print("Destroying device")
        vkDestroyDevice(pointer, nil)
    }
}