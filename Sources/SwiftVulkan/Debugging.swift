
import CVulkan

func debugger(messageSeverity: VkDebugUtilsMessageSeverityFlagBitsEXT,
            messageType: VkDebugUtilsMessageTypeFlagsEXT,
            callbackData: UnsafePointer<VkDebugUtilsMessengerCallbackDataEXT>,
            pUserData: UnsafeRawPointer) -> UInt32 {
    print("You've got mail!")

    return 0
}

func enableDebugging2(createDebugUtilsMessengerEXT: PFN_vkCreateDebugUtilsMessengerEXT,
                     instance: Instance) throws -> VkDebugUtilsMessengerEXT {
    let x = VkDebugUtilsMessengerCreateInfoEXT(

    )

    var result = VkDebugUtilsMessengerEXT(bitPattern: 0)

    var opResult = VK_SUCCESS
    withUnsafePointer(to: x) {
        opResult = createDebugUtilsMessengerEXT(instance.pointer, $0, nil, &result)
    }
    
    guard opResult == VK_SUCCESS else {
        throw opResult.toResult()
    }

    return result!
}