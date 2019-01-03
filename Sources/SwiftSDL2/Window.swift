//
// Created by Alexander Ubillus on 2018-12-30.
//

import Foundation
import CSDL2
import CVulkan
import Darwin

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

//let SDL_WINDOW_SHOWN: Uint32 = 1

let instance = UnsafeMutablePointer<VkInstance?>.allocate(capacity: 1)

var appInfo = VkApplicationInfo(
    sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
    pNext: nil,
    pApplicationName: nil, //"Sample".asCString(),
    applicationVersion: VK_MAKE_VERSION(1, 0, 0),
    pEngineName: nil,
    engineVersion: VK_MAKE_VERSION(1, 0, 0),
    apiVersion: VK_MAKE_VERSION(1, 0, 0)
)

var createInfo = VkInstanceCreateInfo(
    sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
    pNext: nil,
    flags: 0,
    pApplicationInfo: nil, // &appInfo,
    enabledLayerCount: 0,
    ppEnabledLayerNames: nil,
    enabledExtensionCount: 2,
    ppEnabledExtensionNames: nil
)

public func initializeSwiftSDL2() {
    if SDL_Init(SDL_INIT_VIDEO|SDL_INIT_EVENTS) < 0 {
        print("Some Issue")
        return
    }

    let _ = VulkanAPI.vkEnumerateInstanceLayerProperties()
    
    let initResult = initVulkan() 
    if initResult != VK_SUCCESS {
        print("Error initializing vulkan: \(initResult)")
        exit(-1)
    }
}

func initVulkan() -> VkResult {
    var result = VK_ERROR_INITIALIZATION_FAILED

    if result != VK_SUCCESS {
        instance.initialize(to: VkInstance(bitPattern: 0))

        let extensions = [
            VK_KHR_SURFACE_EXTENSION_NAME, 
            VK_MVK_MACOS_SURFACE_EXTENSION_NAME
        ]

        let convExtesions = extensions.map { $0.asCString() }

        let _ = VulkanAPI.vkEnumerateInstanceExtensionProperties(nil)


        createInfo.ppEnabledExtensionNames = UnsafePointer(convExtesions)

        let createInfoPtr = UnsafePointer(&createInfo)
        let pointerToArray = createInfoPtr.pointee.ppEnabledExtensionNames!
        print("Outside method: ")
        print("address: \(pointerToArray[0]!)")
        print("\\-string: \(String(cString: pointerToArray[0]!))")
        print("address: \(pointerToArray[1]!)")
        print("\\-string: \(String(cString: pointerToArray[1]!))")
        print("=====")
        result = vkCreateInstance(createInfoPtr, nil, instance);
        print("After method: ")
        print("address: \(pointerToArray[0]!)")
        print("\\-string: \(String(cString: pointerToArray[0]!))")
        print("address: \(pointerToArray[1]!)")
        print("\\-string: \(String(cString: pointerToArray[1]!))")
        print("=====")
    }

    return result;
}

public func asCStringArray(_ args: [String]) -> UnsafePointer<UnsafePointer<Int8>?>? {
    let cstrs = args.map { $0.asCString() }
    let pointerToArray = UnsafePointer(cstrs)

    print("In method: ")
    print("address: \(pointerToArray[0]!)")
            print("\\-string: \(String(cString: pointerToArray[0]!))")
            print("address: \(pointerToArray[1]!)")
            print("\\-string: \(String(cString: pointerToArray[1]!))")
    print("=====")

    return pointerToArray 
}

public func deinitializeSwiftSDL2() {
    SDL_Quit()
}

public class Window {

    var window: OpaquePointer?

    public init() {
        window = SDL_CreateWindow(
                "SDL Tutorial", 100, 100, 1024, 768,
                WindowFlags.SDL_WINDOW_SHOWN.rawValue | 
                WindowFlags.SDL_WINDOW_ALWAYS_ON_TOP.rawValue | 
                WindowFlags.SDL_WINDOW_VULKAN.rawValue
        );

        if window == nil {
            let error = SDL_GetError()
            let errorCode = String(cString: error!)
            print("Window could not be created! SDL_Error: \(errorCode)\n");
            exit(-1)
        } else {
            //Get window surface
            let screenSurface: UnsafeMutablePointer<SDL_Surface> = SDL_GetWindowSurface(window)

            //Fill the surface white
            let rv = SDL_FillRect(screenSurface, nil, SDL_MapRGB(screenSurface.pointee.format, 0xFF, 0xFF, 0xFF))

            print("SDL_FillRect returned \(rv)")

            //Update the surface
            SDL_UpdateWindowSurface(window)

            print("SDL_UpdateWindowSurface returned \(rv)")

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
        }
    }

    deinit {
        //Destroy window
        SDL_DestroyWindow(window);
    }

}

extension String {
    public func asCString() -> UnsafePointer<Int8>? {
        let nsVal = self as NSString
        return nsVal.cString(using: String.Encoding.utf8.rawValue)
    }
}