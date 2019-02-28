
import CVulkan

public class BufferCreateInfo {
    public var flags: Flags
    public var size: DeviceSize
    public var usage: BufferUsageFlags
    public var sharingMode: SharingMode
    public var queueFamilyIndices: [UInt32]?

    public init(flags: Flags,
                size: DeviceSize,
                usage: BufferUsageFlags,
                sharingMode: SharingMode,
                queueFamilyIndices: [UInt32]?) {
        self.flags = flags
        self.size = size
        self.usage = usage
        self.sharingMode = sharingMode
        self.queueFamilyIndices = queueFamilyIndices
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let none = Flags(rawValue: 0)
        public static let sparseBinding = Flags(rawValue: 0x00000001)
        public static let sparseResidency = Flags(rawValue: 0x00000002)
        public static let sparseAliased = Flags(rawValue: 0x00000004)
        public static let protected = Flags(rawValue: 0x00000008)
        public static let deviceAddressCaptureReplay = Flags(rawValue: 0x00000010)
    }

    var vulkan: VkBufferCreateInfo {
        return VkBufferCreateInfo(
                sType: VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
                pNext: nil,
                flags: self.flags.rawValue,
                size: self.size,
                usage: self.usage.vulkan,
                sharingMode: self.sharingMode.vulkanValue,
                queueFamilyIndexCount: UInt32(self.queueFamilyIndices?.count ?? 0),
                pQueueFamilyIndices: self.queueFamilyIndices
        )
    }
}

public class Buffer {
    public let pointer: VkBuffer
    public let device: Device

    public var boundMemory: DeviceMemory? = nil

    init(pointer: VkBuffer,
        device: Device) {
        self.pointer = pointer
        self.device = device
    }

    public lazy var memoryRequirements: MemoryRequirements = {
        var reqs = [VkMemoryRequirements()]
        vkGetBufferMemoryRequirements(self.device.pointer, self.pointer, &reqs)

        return MemoryRequirements(reqs[0])
    }()

    public class func create(device: Device, createInfo: BufferCreateInfo) throws -> Buffer {

        var buffer = VkBuffer(bitPattern: 0)
        let opResult = withUnsafePointer(to: createInfo.vulkan) {
            return vkCreateBuffer(device.pointer, $0, nil, &buffer)
        }
        
        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return Buffer(pointer: buffer!, device: device)
    }

    public func bindMemory(memory: DeviceMemory, offset: DeviceSize = 0) throws {
        let opResult = vkBindBufferMemory(self.device.pointer, self.pointer, memory.pointer, offset)

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        self.boundMemory = memory
    }

    deinit {
        vkDestroyBuffer(self.device.pointer, self.pointer, nil)
    }
}