//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//  

import CSDL2
import SwiftVulkan
import SGLMath

let SDL_WINDOWPOS_UNDEFINED_MASK: Int32 = 0x1FFF0000;
let SDL_WINDOWPOS_UNDEFINED = SDL_WINDOWPOS_UNDEFINED_MASK;

enum WindowFlags: UInt32 {
    case SDL_WINDOW_FULLSCREEN = 0x00000001
    case SDL_WINDOW_SHOWN = 0x00000004
    case SDL_WINDOW_HIDDEN = 0x00000008
    case SDL_WINDOW_RESIZABLE = 0x00000020
    case SDL_WINDOW_MINIMIZED = 0x00000040
    case SDL_WINDOW_MAXIMIZED = 0x00000080
    case SDL_WINDOW_ALWAYS_ON_TOP = 0x00008000
    case SDL_WINDOW_VULKAN = 0x10000000
}

public func initializeSwiftSDL2() {
    if SDL_Init(SDL_INIT_VIDEO|SDL_INIT_EVENTS) < 0 {
        print(lastSDLError())
        return
    }
}

public func deinitializeSwiftSDL2() {
    SDL_Quit()
}

public class Window {

    var window: OpaquePointer?
    var instance: Instance?

    public init() {
        self.window = SDL_CreateWindow(
                "Vulkan Sample", 100, 100, 1024, 768,
                WindowFlags.SDL_WINDOW_SHOWN.rawValue | 
                WindowFlags.SDL_WINDOW_ALWAYS_ON_TOP.rawValue | 
                WindowFlags.SDL_WINDOW_VULKAN.rawValue
        );

        guard window != nil else {
            print("Error while creating window")
            return
        }
        
        do {
            print("1== CREATE VULKAN INSTANCE")
            let extensions = try getInstanceExtensions()
            self.instance = try createVulkanInstance(extensions)

            print("2== CREATE PHYSICAL DEVICE")
            let gpu = try selectPhysicalDevice()
            print("Created GPU (Physical device): \(gpu.pointer)\n")

            print("3== CREATE SURFACE (Metal->MoltenVK) using SDL")
            let surface = try createVulkanSurface()
            print("Created Surface: \(surface.pointer)\n")

            print("4== CREATE DEVICE")
            let device = try createDevice(gpu: gpu, surface: surface)
            print("Created Device: \(device.pointer)\n")

            print("5== CREATE SWAPCHAIN")
            let (info, swapchain) = try createSwapchain(gpu: gpu, surface: surface, device: device)
            print("Created Swapchain: \(swapchain.pointer)\n")
            
            print("6== CREATE COMMAND POOL")
            let commandPool = try createCommandPool(device)
            print("Created Command Pool: \(commandPool.pointer)\n")

            print("7== CREATE COMMAND BUFFER")
            let commandBuffer = try allocateCommandBuffer(device: device, commandPool: commandPool)
            print("Created Command Buffer: \(commandBuffer.pointer)\n")

            print("8== GET SWAPCHAIN IMAGES")
            let images = try swapchain.getSwapchainImages()
            print("Get swapchain images: \(images)\n")

            print("9== GET QUEUE")
            let queue = device.createQueue(presentFamilyIndex: 0)
            print("Present queue: \(queue.pointer)\n")

            print("10== CREATE DEPTH BUFFER")
            let depthBuffer = try createDepthBuffer(device: device, gpu: gpu, extent: info.imageExtent)
            print("Depth buffer: \(depthBuffer.pointer)\n")

            print("11== CREATE DEPTH BUFFER")
            let uniformBuffer = try getUniformBuffer(device: device)
            print("Uniform buffer: \(uniformBuffer.pointer)\n")

            runMessageLoop()
            print("Done")
        } catch {
            print("FATAL ERROR: \(error)")
        }
    }

    func getUniformBuffer(device: Device) throws -> Buffer {

        let projection = SGLMath.perspective(radians(45), Float(1.0), Float(0.1), Float(100))
        let view = SGLMath.lookAt(
            vec3(-5.0, 3, -10),
            vec3(0, 0, 0),
            vec3(0, -1, 0))
        let model = mat4(1.0)

        let clip = mat4(
            1.0, 0.0, 0.0, 0.0,
            0.0,-1.0, 0.0, 0.0,
            0.0, 0.0, 0.5, 0.0,
            0.0, 0.0, 0.5, 1.0
        )

        let mvp = clip * projection * view * model

        let createInfo = BufferCreateInfo(
            flags: .none,
            size: UInt64(MemoryLayout.size(ofValue: clip)),
            usage: .uniformBuffer,
            sharingMode: .exclusive,
            queueFamilyIndices: nil
        )

        let buffer = try Buffer.create(device: device, createInfo: createInfo)

        return buffer
    }

    func createDepthBuffer(device: Device, gpu: PhysicalDevice, extent: Extent2D) throws -> ImageView {
        let threeDeeExtent = extent.to3D(withDepth: 1)

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
            format: .D16_UNORM,
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

        guard index >= 0 else {
            print("Failed to find a compatibly memory type")
            exit(-1)
        }

        let mem = try device.allocateMemory(allocInfo: memAlloc)
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

        return try ImageView.create(device: device, createInfo: viewCreateInfo)
    }

    func memoryTypeFromProperties(gpu: PhysicalDevice, 
                                typeFlags: UInt32, 
                                requirementsMask: MemoryPropertyFlags) throws -> Int {
        let memProps = try gpu.getMemoryProperties()
        var index = UInt32(0)
        for memType in memProps.memoryTypes {
            if typeFlags & 1 == 1 {
                if memType.propertyFlags.rawValue == requirementsMask.rawValue {
                    return Int(index)
                }
            }
            index = index + 1
        }

        return -1
    }

    func createSwapchain(gpu: PhysicalDevice, surface: Surface, device: Device) throws -> (SwapchainCreateInfo, Swapchain) {

        let capabilities = try gpu.getSurfaceCapabilities(surface: surface)
        let surfaceFormat = try selectFormat(for: gpu, surface: surface)

        let presentModes = try gpu.getSurfacePresentModes(surface: surface)
        print("Present modes available for swapchain: \(presentModes)")

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
        
        let info = SwapchainCreateInfo(
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

        print("Swapchain parameters: \(info)")

        return (info, try device.createSwapchain(createInfo: info))
    }

    func allocateCommandBuffer(device: Device, commandPool: CommandPool) throws -> CommandBuffer {
        let info = CommandBufferAllocateInfo(
            commandPool: commandPool,
            level: .primary,
            commandBufferCount: 1
        )

        return try device.allocateCommandBuffer(createInfo: info)
    }

    func selectFormat(for gpu: PhysicalDevice, surface: Surface) throws -> SurfaceFormat {
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

    func runMessageLoop() {
        var quit = false

        let e: UnsafeMutablePointer<SDL_Event>? = UnsafeMutablePointer<SDL_Event>.allocate(capacity: 1)

        while (!quit) {
            SDL_PollEvent(e)

            guard let event = e?.pointee else {
                continue
            }
        
            if event.type == SDL_QUIT.rawValue {
                quit = true
                break
            }
        }
    }

    func createVulkanInstance(_ extensions: [String]) throws -> Instance? {
        let extensionProps = try enumerateInstanceExtensionProperties(nil) 
        let actualExtensions = extensionProps.map { $0.extensionName } 
        
        print("Enabling extensions:")
        for ext in actualExtensions {
            print("\(ext)")
        }
        print("===\n")

        let createInfo = InstanceCreateInfo(
            applicationInfo: nil,
            enabledLayerNames: [ "VK_LAYER_LUNARG_standard_validation" ],
            enabledExtensionNames: actualExtensions 
        )

        return try Instance.createInstance(createInfo: createInfo)
    }

    func createVulkanSurface() throws -> Surface {
        var surface = VkSurfaceKHR(bitPattern: 0)

        if SDL_Vulkan_CreateSurface(window, self.instance!.pointer, &surface) != SDL_TRUE {
            throw lastSDLError()
        }

        return Surface(instance: self.instance!, surface: surface!)
    }

    func selectPhysicalDevice() throws -> PhysicalDevice {
        let gpus = try self.instance!.enumeratePhysicalDevices()
        let gpu = gpus[0]
        let extensions = try gpu.getExtensionProperties()

        for ext in extensions {
            print("Device extension: \(ext)")
        }

        return gpu
    }

    func createDevice(gpu: PhysicalDevice, surface: Surface) throws -> Device {
        
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
                        queuePriorities: [ 1.0 ]
                    )
                ],
                enabledLayers: [],
                enabledExtensions: [ "VK_KHR_swapchain" ],
                enabledFeatures: nil
            )

            // use first device
            return try gpu.createDevice(createInfo: createInfo)
        } else {
            throw SDLError.vulkan(msg: "Unable to find a queue family with surface presentation support")
        }
    }

    func createCommandPool(_ device: Device) throws -> CommandPool {
        let info = CommandPoolCreateInfo(
            flags: .none,
            queueFamilyIndex: 0
        )

        // create command pool
        return try device.createCommandPool(createInfo: info)
    }

    func getInstanceExtensions() throws -> [String] {
        var opResult = SDL_FALSE
        var countArr: [UInt32] = [0]
        var result: [String] = []

        opResult = SDL_Vulkan_GetInstanceExtensions(self.window, &countArr, nil)
        if opResult != SDL_TRUE {
            throw lastSDLError()
        }

        let count = Int(countArr[0])
        if count > 0 {
            let namesPtr = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: count)
            defer {
                namesPtr.deallocate()
            }

            opResult = SDL_Vulkan_GetInstanceExtensions(self.window, &countArr, namesPtr)
            
            if opResult == SDL_TRUE {
                for i in 0..<count {
                    let namePtr = namesPtr[i]
                    let newName = String(cString: namePtr!)
                    result.append(newName)
                }
            }
        }

        return result
    }

    deinit {
        //Destroy window
        SDL_DestroyWindow(window);
    }
}

enum SDLError: Error {
    case generic(msg: String)
    case vulkan(msg: String)
}

func lastSDLError() -> SDLError {
    let error = SDL_GetError()
    return .generic(msg: String(cString: error!))
}