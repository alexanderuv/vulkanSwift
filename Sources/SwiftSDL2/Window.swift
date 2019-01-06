//
// Created by Alexander Ubillus on 2018-12-30.
//

import Foundation
import CSDL2
import Darwin
import SwiftVulkan
import MetalKit

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
        print("Some Issue")
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
        
        let extensions = getInstanceExtensions()
        self.instance = createVulkanInstance(extensions)

        let gpu = selectPhysicalDevice()
        let surface = try! createVulkanSurface()
        let device = try! createDevice(gpu: gpu, surface: surface)

        //let selectedFormat = selectFormat(for: gpu, surface: surface) 
        
        let commandPool = try! createCommandPool(device)
        let commandBuffer = try! allocateCommandBuffer(device: device, commandPool: commandPool)
        
        runMessageLoop()
        print("Done")
    }

    func allocateCommandBuffer(device: Device, commandPool: CommandPool) -> CommandBuffer {
        let info = CommandBufferAllocateInfo(
            commandPool: commandPool,
            level: .primary,
            commandBufferCount: 1
        )

        return try! device.allocateCommandBuffer(createInfo: info)
    }

    // func selectFormat(for gpu: PhysicalDevice, surface: Surface)  {
    //     let (result, formats) = gpu.getSurfaceFormats(for: surface)
    //     if let formats = formats {

    //         var chosenFormat: Format? = nil
    //         for format in formats {
    //             if format.format == .VK_FORMAT_B8G8R8A8_SRGB {
    //                 chosenFormat = format.format
    //             }
    //         }

    //         let presentModes = gpu.getSurfacePresentModes(surface: surface)
    //         if !presentModes.contains(.fifo) {
    //             return
    //         }


    //     }
        
    // }

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

    func createVulkanInstance(_ extensions: [String]) -> Instance? {
        let layerProps = enumerateInstanceLayerProperties()
        print("\(layerProps.count) layer properties were found")

        let extensionProps = enumerateInstanceExtensionProperties(nil)
        print("\(extensionProps.count) extension properties were found")

        let createInfo = InstanceCreateInfo(
            applicationInfo: nil,
            enabledLayerNames: ["VK_LAYER_LUNARG_standard_validation"],
            enabledExtensionNames: extensions
        )

        let (result, inst) = Instance.createInstance(createInfo: createInfo)
        if let instance = inst {
            return instance
        }

        handleVulkanError(result)
        return nil
    }

    func createVulkanSurface() throws -> Surface {
        let surfacePtr = UnsafeMutablePointer<VkSurfaceKHR?>.allocate(capacity: 1)
        if SDL_Vulkan_CreateSurface(window, self.instance!.pointer, surfacePtr) != SDL_TRUE {
            throw lastSDLError()
        }

        return Surface(instance: self.instance!, surface: surfacePtr.pointee!)
    }

    func selectPhysicalDevice() -> PhysicalDevice {
        let gpus = self.instance!.enumeratePhysicalDevices()

        for gpu in gpus {
            let gpuProps = gpu.properties
            print("GPU Properties:\n\(gpuProps)") 
        }

        return gpus[0]
    }

    func createDevice(gpu: PhysicalDevice, surface: Surface) throws -> Device {
        
        var chosenQueueFamily: QueueFamilyProperties? = nil
        for fam in gpu.queueFamilyProperties {
            if try! gpu.hasSurfaceSupport(for: fam, surface: surface) {
                chosenQueueFamily = fam
                break
            }
        }
        
        if let chosenQueueFamily = chosenQueueFamily {

            print("Queue Family is \(chosenQueueFamily.index)")

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
                enabledExtensions: [],
                enabledFeatures: nil
            )

            // use first device
            return try! gpu.createDevice(createInfo: createInfo)
        } else {
            throw SDLError.vulkan(msg: "Unable to find a queue family with surface presentation support")
        }
    }

    func createCommandPool(_ device: Device) -> CommandPool {
        let info = CommandPoolCreateInfo(
            flags: .none,
            queueFamilyIndex: 0
        )

        // create command pool
        return try! device.createCommandPool(createInfo: info)
    }

    func handleVulkanError(_ r: Result) {
        print("Vulkan error: \(r)")
    }

    func lastSDLError() -> SDLError {
        let error = SDL_GetError()
        return .generic(msg: String(cString: error!))
    }

    func getInstanceExtensions() -> [String] {
       let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }
        
        var opResult = SDL_Vulkan_GetInstanceExtensions(self.window, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [String] = []
        if opResult == SDL_TRUE && count > 0 {
            let namesPtr = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: count)
            defer {
                namesPtr.deallocate()
            }

            opResult = SDL_Vulkan_GetInstanceExtensions(self.window, countPtr, namesPtr)
            count = Int(countPtr.pointee)

            if opResult == SDL_TRUE {
                for i in 0..<count {
                    let namePtr = namesPtr[i]
                    let newName = String(cString: namePtr!)

                    print("Extension name: \(newName)")
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