//
// Created by Alexander Ubillus on 2019-01-27.
//

import Foundation
import SwiftSDL2
import SwiftVulkan
import SGLMath

public class VulkanSample {
    public let window: Window
    public let instance: Instance // vulkan instance
    public let surface: SurfaceKHR
    public let gpu: PhysicalDevice
    public let device: Device
    public var swapchain: Swapchain? = nil
    public var commandPool: CommandPool? = nil
    public var commandBuffer: CommandBuffer? = nil
    public var queue: Queue? = nil
    public var depthBuffer: ImageView? = nil
    public var descriptorSet: DescriptorSet? = nil
    public var descriptorPool: DescriptorPool? = nil
    public var renderPass: RenderPass? = nil

    // swapchain data
    public var swapchainFormat: Format? = nil

    // depth buffer
    public var depthBufferFormat: Format? = nil

    // uniform data
    public var uniformBuffer: Buffer? = nil
    public var uniformDescriptorBufferInfo: DescriptorBufferInfo? = nil

    // matrix data
    private var projection: mat4? = nil
    private var view: mat4? = nil
    private var model: mat4? = nil
    private var clip: mat4? = nil
    private var mvp: mat4? = nil

    public var swapchainCreateInfo: SwapchainCreateInfo? = nil
    public var swapchainImages: [Image]? = nil

    public init?() throws {
        let window = Window() // create window
        guard window != nil else {
            print("Unable to create SDL window")
            return nil
        }

        self.window = window!
        let extensions = try self.window.getInstanceExtensions()

        // create instance
        let inst = try VulkanSample.createVulkanInstance(extensions)
        guard inst != nil else {
            print("Unable to create vulkan instance")
            return nil
        }
        self.instance = inst!

        // create surface
        self.surface = try self.window.createVulkanSurface(instance: self.instance)

        // select physical device (gpu)
        self.gpu = try VulkanSample.selectPhysicalDevice(instance: self.instance)

        // create logical device
        self.device = try VulkanSample.createDevice(gpu: self.gpu, surface: self.surface)
    }

    public func initialize() throws {
        do {
            try initializeSwapchain()
            try initializeCommands()
            try initializeQueue()
            try initializeBuffers()

            try createRenderPass()
        } catch {
            print("Error initializing: \(error)")
            //throw
        }
    }

    func initializeBuffers() throws {
        self.depthBuffer = try createDepthBuffer()
        self.uniformBuffer = try createUniformBuffer()
        self.descriptorSet = try createDescriptorSet()
    }

    func initializeQueue() throws {
        self.queue = Queue.create(fromDevice: self.device, presentFamilyIndex: 0)
    }

    func initializeCommands() throws {
        let info = CommandPoolCreateInfo(
                flags: .none,
                queueFamilyIndex: 0
        )

        // create command pool
        self.commandPool = try CommandPool.create(from: device, info: info)

        let allocateInfo = CommandBufferAllocateInfo(
                commandPool: self.commandPool!,
                level: .primary,
                commandBufferCount: 1
        )

        self.commandBuffer = try CommandBuffer.allocate(device: device, allocInfo: allocateInfo)
    }

    func initializeSwapchain() throws {

        let capabilities = try gpu.getSurfaceCapabilities(surface: surface)
        let surfaceFormat = try selectFormat(for: gpu, surface: surface)

        //let presentModes = try gpu.getSurfacePresentModes(surface: surface)
        let preTransform = capabilities.supportedTransforms.contains(.identity) ?
                .identity : capabilities.currentTransform

        // Find a supported composite alpha mode - one of these is guaranteed to be set
        var compositeAlpha: CompositeAlphaFlags = .opaque;
        let desiredCompositeAlpha =
                [compositeAlpha, .preMultiplied, .postMultiplied, .inherit]

        for desired in desiredCompositeAlpha {
            if capabilities.supportedCompositeAlpha.contains(desired) {
                compositeAlpha = desired
                break
            }
        }

        self.swapchainFormat = surfaceFormat.format

        self.swapchainCreateInfo = SwapchainCreateInfo(
                flags: .none,
                surface: surface,
                minImageCount: capabilities.maxImageCount,
                imageFormat: surfaceFormat.format,
                imageColorSpace: surfaceFormat.colorSpace,
                imageExtent: capabilities.maxImageExtent,
                imageArrayLayers: 1,
                imageUsage: .colorAttachment,
                imageSharingMode: .exclusive,
                queueFamilyIndices: [0],
                preTransform: preTransform,
                compositeAlpha: compositeAlpha,
                presentMode: .fifo,
                clipped: true,
                oldSwapchain: nil
        )

        self.swapchain = try Swapchain.create(inDevice: self.device, createInfo: self.swapchainCreateInfo!)
        self.swapchainImages = try self.swapchain!.getSwapchainImages()
    }

    class func createVulkanInstance(_ extensions: [String]) throws -> Instance? {
        let extensionProps = try Instance.enumerateExtensionProperties(nil)
        let actualExtensions = extensionProps.map {
            $0.extensionName
        }

        print("Enabling extensions:")
        for ext in actualExtensions {
            print("\(ext)")
        }
        print("===\n")

        let createInfo = InstanceCreateInfo(
                applicationInfo: nil,
                enabledLayerNames: ["VK_LAYER_LUNARG_standard_validation"],
                enabledExtensionNames: actualExtensions
        )

        return try Instance.createInstance(createInfo: createInfo)
    }

    class func selectPhysicalDevice(instance: Instance) throws -> PhysicalDevice {
        let gpus = try instance.enumeratePhysicalDevices()

        return gpus[0]
    }

    class func createDevice(gpu: PhysicalDevice, surface: SurfaceKHR) throws -> Device {

        var chosenQueueFamily: QueueFamilyProperties? = nil
        for fam in gpu.queueFamilyProperties {
            if try gpu.hasSurfaceSupport(for: fam, surface: surface) {
                chosenQueueFamily = fam
                break
            }
        }

        if let chosenQueueFamily = chosenQueueFamily {
            print("Chosen queue Family is \(chosenQueueFamily.index)")

            let createInfo = DeviceCreateInfo(
                    flags: .none,
                    queueCreateInfos: [
                        DeviceQueueCreateInfo(
                                flags: .none,
                                queueFamilyIndex: chosenQueueFamily.index,
                                queuePriorities: [1.0]
                        )
                    ],
                    enabledLayers: [],
                    enabledExtensions: ["VK_KHR_swapchain"],
                    enabledFeatures: nil
            )

            // use first device
            return try gpu.createDevice(createInfo: createInfo)
        } else {
            throw SDLError.vulkan(msg: "Unable to find a queue family with surface presentation support")
        }
    }
    
    func setupShaders() throws {
        let vertShaderText = """
#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (std140, binding = 0) uniform bufferVals {
    mat4 mvp;
} myBufferVals;

layout (location = 0) in vec4 pos;
layout (location = 1) in vec4 inColor;
layout (location = 0) out vec4 outColor;

void main() {
   outColor = inColor;
   gl_Position = myBufferVals.mvp * pos;
}
"""
        let fragShaderText = """
#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
layout (location = 0) in vec4 color;
layout (location = 0) out vec4 outColor;
void main() {
   outColor = color;
}
"""

    }

    func createRenderPass() throws {
        let attachments = [
            AttachmentDescription(
                    flags: .none,
                    format: self.swapchainFormat!, // image
                    samples: ._1bit,
                    loadOp: .clear,
                    storeOp: .store,
                    stencilLoadOp: .dontCare,
                    stencilStoreOp: .dontCare,
                    initialLayout: .undefined,
                    finalLayout: .presentSrc),
            AttachmentDescription(
                    flags: .none,
                    format: self.depthBufferFormat!, // depth format
                    samples: ._1bit,
                    loadOp: .clear,
                    storeOp: .dontCare,
                    stencilLoadOp: .dontCare,
                    stencilStoreOp: .dontCare,
                    initialLayout: .undefined,
                    finalLayout: .depthStencilAttachmentOptimal)
        ]

        let colorReference = AttachmentReference(attachment: 0, layout: .colorAttachmentOptimal)
        let depthReference = AttachmentReference(attachment: 1, layout: .depthStencilAttachmentOptimal)

        let subpass = SubpassDescription(
                flags: .none,
                pipelineBindPoint: .graphics,
                inputAttachments: [],
                colorAttachments: [colorReference],
                resolveAttachments: [],
                depthStencilAttachment: depthReference,
                preserveAttachments: []
        )

        let createInfo = RenderPassCreateInfo(
                flags: .none,
                attachments: attachments,
                subpasses: [subpass],
                dependencies: nil
        )

        let semaphore = try Semaphore.create(info: SemaphoreCreateInfo(flags: .none), device: self.device)
        try self.swapchain?.acquireNextImage(timeout: UInt64.max, semaphore: semaphore, fence: nil, imageIndex: 0)

        self.renderPass = try RenderPass.create(createInfo: createInfo, device: self.device)
    }

    func createDepthBuffer() throws -> ImageView {
        let threeDeeExtent = self.swapchainCreateInfo!.imageExtent.to3D(withDepth: 1)

        let depthFormat = Format.D16_UNORM
        let formatProps = gpu.getFormatProperties(for: depthFormat)
        var tiling = ImageTiling.optimal

        if formatProps.linearTilingFeatures.contains(.depthStencilAttachment) {
            tiling = .linear
        } else if formatProps.optimalTilingFeatures.contains(.depthStencilAttachment) {
            tiling = .optimal
        } else {
            /* Try other depth formats? */
            print("VK_FORMAT_D16_UNORM Unsupported.")
            exit(-1)
        }

        let createInfo = ImageCreateInfo(
                flags: .none,
                imageType: .type2D,
                format: depthFormat,
                extent: threeDeeExtent,
                mipLevels: 1,
                arrayLayers: 1,
                samples: ._1bit,
                tiling: tiling,
                usage: .depthStencilAttachment,
                sharingMode: .exclusive,
                queueFamilyIndices: nil,
                initialLayout: .undefined
        )

        let image = try Image.create(withInfo: createInfo, device: device)
        let memReqs = image.memoryRequirements

        let memAlloc = MemoryAllocateInfo(
                allocationSize: memReqs.size,
                memoryTypeIndex: 0
        )

        let index = try memoryTypeFromProperties(gpu: gpu,
                typeFlags: memReqs.memoryTypeBits,
                requirementsMask: .deviceLocal)

        guard index != nil else {
            print("Failed to find a compatibly memory type")
            exit(-1)
        }

        let mem = try DeviceMemory.allocateMemory(inDevice: device, allocInfo: memAlloc)
        try image.bindMemory(memory: mem)

        let viewCreateInfo = ImageViewCreateInfo(
                flags: .none,
                image: image,
                viewType: .type2D,
                format: depthFormat,
                components: .identity,
                subresourceRange: ImageSubresourceRange(
                        aspectMask: .depth,
                        baseMipLevel: 0,
                        levelCount: 1,
                        baseArrayLayer: 0,
                        layerCount: 1
                )
        )

        self.depthBufferFormat = depthFormat

        return try ImageView.create(device: device, createInfo: viewCreateInfo)
    }

    func createUniformBuffer() throws -> Buffer {

        self.projection = SGLMath.perspective(radians(45), Float(1.0), Float(0.1), Float(100))
        self.view = SGLMath.lookAt(
                vec3(-5.0, 3, -10),
                vec3(0, 0, 0),
                vec3(0, -1, 0))

        self.model = mat4(1.0)

        self.clip = mat4(
                1.0, 0.0, 0.0, 0.0,
                0.0, -1.0, 0.0, 0.0,
                0.0, 0.0, 0.5, 0.0,
                0.0, 0.0, 0.5, 1.0
        )

        mvp = clip! * projection! * view! * model!

        let createInfo = BufferCreateInfo(
                flags: .none,
                size: UInt64(MemoryLayout.size(ofValue: clip)),
                usage: .uniformBuffer,
                sharingMode: .exclusive,
                queueFamilyIndices: nil
        )

        let buffer = try Buffer.create(device: device, createInfo: createInfo)

        let allocInfo = MemoryAllocateInfo(
                allocationSize: buffer.memoryRequirements.size,
                memoryTypeIndex: try memoryTypeFromProperties(
                        gpu: gpu,
                        typeFlags: buffer.memoryRequirements.memoryTypeBits,
                        requirementsMask: [.hostVisible, .hostCoherent]) ?? 0
        )

        let memory = try DeviceMemory.allocateMemory(inDevice: device, allocInfo: allocInfo)

        try memory.mapMemory(offset: 0, size: allocInfo.allocationSize, flags: .none, data: mvp!)
        memory.unmapMemory()

        try buffer.bindMemory(memory: memory)

        return buffer
    }

    func createDescriptorSet() throws -> DescriptorSet {

        let buffer = self.uniformBuffer!
        let (descLayout, pipelineLayout) = try createPipelineLayout()

        let poolSize = DescriptorPoolSize(
                type: .uniformBuffer,
                descriptorCount: 1
        )

        let info = DescriptorPoolCreateInfo(
                flags: .none,
                maxSets: 1,
                poolSizes: [poolSize]
        )

        self.descriptorPool = try DescriptorPool.create(device: device, createInfo: info)

        let allocInfo = DescriptorSetAllocateInfo(
                descriptorPool: self.descriptorPool!,
                descriptorSetCount: 1,
                setLayouts: [descLayout]
        )

        let ds = try device.allocateDescriptorSets(allocateInfo: allocInfo)

        self.uniformDescriptorBufferInfo = DescriptorBufferInfo(
                buffer: buffer,
                offset: 0,
                range: UInt64(MemoryLayout.size(ofValue: self.mvp!))
        )

        let wds = WriteDescriptorSet(
                dstSet: ds,
                dstBinding: 0,
                dstArrayElement: 0,
                descriptorCount: 1,
                descriptorType: .uniformBuffer,
                imageInfo: nil,
                bufferInfo: self.uniformDescriptorBufferInfo!,
                texelBufferView: nil
        )

        device.updateDescriptorSets(descriptorWrites: [wds], descriptorCopies: [])

        return ds
    }

    func createPipelineLayout() throws -> (DescriptorSetLayout, PipelineLayout) {
        let layoutBinding = DescriptorSetLayoutBinding(
                binding: 0,
                descriptorType: .uniformBuffer,
                descriptorCount: 1,
                stageFlags: .vertex,
                immutableSamplers: nil
        )

        let createInfo = DescriptorSetLayoutCreateInfo(
                flags: .none,
                bindings: [layoutBinding]
        )

        let layout = try DescriptorSetLayout.create(device: device, createInfo: createInfo)

        let pipelineCreateInfo = PipelineLayoutCreateInfo(
                flags: .none,
                setLayouts: [layout],
                pushConstantRanges: []
        )

        let pipelineLayout = try PipelineLayout.create(device: device, createInfo: pipelineCreateInfo)

        return (layout, pipelineLayout)
    }

    func memoryTypeFromProperties(gpu: PhysicalDevice,
                                  typeFlags: UInt32,
                                  requirementsMask: MemoryPropertyFlags) throws -> UInt32? {
        let memProps = try gpu.getMemoryProperties()
        var currentTypeFlags = typeFlags
        for i in 0..<memProps.memoryTypes.count {
            if typeFlags & 1 == 1 {
                if (memProps.memoryTypes[i].propertyFlags.rawValue & requirementsMask.rawValue) == requirementsMask.rawValue {
                    return UInt32(i)
                }
            }
            currentTypeFlags = currentTypeFlags >> 1
        }

        return nil
    }

    func selectFormat(for gpu: PhysicalDevice, surface: SurfaceKHR) throws -> SurfaceFormat {
        let formats = try gpu.getSurfaceFormats(for: surface)

        for format in formats {
            if format.format == .R8G8B8A8_UNORM {
                return format
            }
        }

        for format in formats {
            if format.format == .B8G8R8A8_SRGB {
                return format
            }
        }

        return formats[0]
    }

    public func run() {
        self.window.runMessageLoop()
    }
}
