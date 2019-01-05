//
// Created by Alexander Ubillus on 2018-12-30.
//

import Foundation
import CSDL2
import Darwin
import SwiftVulkan

let SDL_WINDOWPOS_UNDEFINED_MASK: Int32 = 0x1FFF0000;
let SDL_WINDOWPOS_UNDEFINED = SDL_WINDOWPOS_UNDEFINED_MASK;

func VK_MAKE_VERSION (_ major: UInt32,_ minor: UInt32,_ patch: UInt32) -> UInt32 {
    return (major << 22) | (minor << 12) | patch
}

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

// var appInfo = VkApplicationInfo(
//     sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
//     pNext: nil,
//     pApplicationName: nil, //"Sample".asCString(),
//     applicationVersion: VK_MAKE_VERSION(1, 0, 0),
//     pEngineName: nil,
//     engineVersion: VK_MAKE_VERSION(1, 0, 0),
//     apiVersion: VK_MAKE_VERSION(1, 0, 0)
// )

public func initializeSwiftSDL2() {
    if SDL_Init(SDL_INIT_VIDEO|SDL_INIT_EVENTS) < 0 {
        print("Some Issue")
        return
    }
}

func initVulkan(_ extensions: [String]) -> Instance? {

    let layerProps = vkEnumerateInstanceLayerProperties()
    print("\(layerProps.count) layer properties were found")

    let extensionProps = vkEnumerateInstanceExtensionProperties(nil)
    print("\(extensionProps.count) extension properties were found")

    let createInfo = VkInstanceCreateInfo(
        applicationInfo: nil,
        enabledLayerNames: ["VK_LAYER_LUNARG_standard_validation"],
        enabledExtensionNames: extensions
    )

    if let instance = try? Instance(info: createInfo) {
        let devices = instance.enumeratePhysicalDevices()

        // for i in 0..<devices.count {
        //     let props = vkGetPhysicalDeviceProperties(devices[i])
        //     print("Device Properties [\(i)]:\n\(props)") 
        // }

        return instance
    }
    
    return nil
}

public func deinitializeSwiftSDL2() {
    SDL_Quit()
}

public class Window {

    var window: OpaquePointer?

    public init() {
        window = SDL_CreateWindow(
                "Vulkan Sample", 100, 100, 1024, 768,
                WindowFlags.SDL_WINDOW_SHOWN.rawValue | 
                WindowFlags.SDL_WINDOW_ALWAYS_ON_TOP.rawValue | 
                WindowFlags.SDL_WINDOW_VULKAN.rawValue
        );

        if let window = window {
            let extensions = getInstanceExtensions(window)

            if let instance = initVulkan(extensions) {
                // if let surface = createSurface(window, instance) {
                    
                     var quit = false

                     let e: UnsafeMutablePointer<SDL_Event>? = UnsafeMutablePointer<SDL_Event>.allocate(capacity: 1)

                    while (!quit) {
                        while true {
                            SDL_PollEvent(e)

                            if let event = e?.pointee {
                                if event.type == SDL_QUIT.rawValue {
                                    quit = true
                                    break
                                }
                            }
                        }
                    }

                    print("Done")
                // }
            } else {
                print("Exiting app")
                exit(1)
            }
        
        } else  {
            let error = SDL_GetError()
            let errorCode = String(cString: error!)
            print("Window could not be created! SDL_Error: \(errorCode)\n");
            exit(-1)
        }
    }

    func getInstanceExtensions(_ window: OpaquePointer) -> [String] {
       let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }
        
        var opResult = SDL_Vulkan_GetInstanceExtensions(window, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [String] = []
        if opResult == SDL_TRUE && count > 0 {
            let namesPtr = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: count)
            defer {
                namesPtr.deallocate()
            }

            opResult = SDL_Vulkan_GetInstanceExtensions(window, countPtr, namesPtr)
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

    // func createSurface(_ window: OpaquePointer, _ instance: VkInstance) -> VkSurfaceKHR? {
    //     let surfacePtr = UnsafeMutablePointer<VkSurfaceKHR?>.allocate(capacity: 1)
    //     defer {
    //             surfacePtr.deallocate()
    //     }

    //     // let opResult = SDL_Vulkan_CreateSurface(window, instance.pointer, surfacePtr)
    //     // if opResult == SDL_TRUE {
    //     //     return VkSurfaceKHR(surfacePtr.pointee!)
    //     // }

    //     return nil
    // }

    deinit {
        //Destroy window
        SDL_DestroyWindow(window);
    }

}

