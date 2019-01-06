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
            printLastSDLError()
            return
        }
        
        let extensions = getInstanceExtensions()
        self.instance = createVulkanInstance(extensions)

        let gpu = selectPhysicalDevice()
        let device = createDevice(gpu)

        guard device != nil else {
            return
        }

        let commandPool = createCommandPool(device!)

        runMessageLoop()     
        print("Done")
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

    func createVulkanSurface() -> Surface? {
        let surfacePtr = UnsafeMutablePointer<VkSurfaceKHR?>.allocate(capacity: 1)
        if SDL_Vulkan_CreateSurface(window, self.instance!.pointer, surfacePtr) != SDL_TRUE {
            printLastSDLError()
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

    func createDevice(_ gpu: PhysicalDevice) -> Device? {
        let queueFamilyProperties = gpu.queueFamilyProperties

        let createInfo = DeviceCreateInfo(
            flags: .none,
            queueCreateInfos: [
                DeviceQueueCreateInfo(
                    flags: .none,
                    queueFamilyIndex: 0,
                    queuePriorities: [ 1.0 ]
                )
            ],
            enabledLayers: [],
            enabledExtensions: [],
            enabledFeatures: nil
        )

        // use first device
        let (result, device) = gpu.createDevice(createInfo: createInfo)
        if let device = device {
            return device
        }

        handleVulkanError(result)
        return nil
    }

    func createCommandPool(_ device: Device) -> CommandPool? {
        let info = CommandPoolCreateInfo(
            flags: .none,
            queueFamilyIndex: 0
        )

        // create command pool
        let (result, pool) = device.createCommandPool(createInfo: info)
        if let pool = pool {
            return pool
        }

        handleVulkanError(result)
        return nil
    }

    func handleVulkanError(_ r: Result) {
        print("Vulkan error: \(r)")
    }

    func printLastSDLError() {
        let error = SDL_GetError()
        let errorCode = String(cString: error!)
        print("SDL_Error: \(errorCode)\n");
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

