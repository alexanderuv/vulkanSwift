//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class CommandPoolCreateInfo {
    public var flags: Flags
    public var queueFamilyIndex: UInt32

    public init(flags: Flags,
                queueFamilyIndex: UInt32) {
        self.flags = flags
        self.queueFamilyIndex = queueFamilyIndex
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let none = Flags(rawValue: 0)
        public static let transient = Flags(rawValue: 1 << 0)
        public static let resetCommandBuffer = Flags(rawValue: 1 << 1)
        public static let protected = Flags(rawValue: 1 << 2)
    }

    func toVulkan() -> VkCommandPoolCreateInfo {
        return VkCommandPoolCreateInfo(
                sType: VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
                pNext: nil,
                flags: self.flags.rawValue,
                queueFamilyIndex: self.queueFamilyIndex
        )
    }
}

public class CommandPool {
    private let device: Device
    public let pointer: VkCommandPool

    init(device: Device, pointer: VkCommandPool) {
        self.device = device
        self.pointer = pointer
    }

    public class func create(from device: Device, info: CommandPoolCreateInfo) throws -> CommandPool {
        var cCommandPool = VkCommandPool(bitPattern: 0)
        var opResult = VK_SUCCESS

        withUnsafePointer(to: info.toVulkan()) {
            opResult = vkCreateCommandPool(device.pointer, $0, nil, &cCommandPool)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return CommandPool(
                device: device,
                pointer: cCommandPool!
        )
    }

    deinit {
        print("Destroying command pool")
        vkDestroyCommandPool(device.pointer, pointer, nil)
    }
}