struct Version {
    let major: Int
    let minor: Int
    let patch: Int

    var rawVersion: UInt32 {
        let val = (major << 22) | (minor << 12) | patch
        return UInt32(val)
    }

    init(from rawValue: UInt32) {
        let val: Int = Int(rawValue)
        patch = val & 0xFFF
        minor = (val & 0x3FF000) >> 12
        major = (val & 0xFFC00000) >> 22
    }
}

class VkApplicationInfo {
    static let sType = VkStructureType.applicationInfo

    // not supported for now
    let next: Any?

    let applicationName: String
    let applicationVersion: UInt32
    let engineName: String
    let engineVersion: UInt32
    let apiVersion: UInt32

    init(_ applicationName: String, 
        applicationVersion: Version, 
        engineName: String,
        engineVersion: Version,
        apiVersion: Version) {
        self.applicationName = applicationName
        self.applicationVersion = applicationVersion.rawVersion
        self.engineName = engineName
        self.engineVersion = engineVersion.rawVersion
        self.apiVersion = apiVersion.rawVersion
        self.next = nil
    }
}

public class VkInstanceCreateInfo {
    static let sType = VkStructureType.instanceCreateInfo
    let next: Any? = nil
    let flags = 0

    let applicationInfo: VkApplicationInfo?
    let enabledLayerNames: [String]
    let enabledExtensionNames: [String]

    init(applicationInfo: VkApplicationInfo?,
        enabledLayerNames: [String],
        enabledExtensionNames: [String]) {
        self.applicationInfo = applicationInfo
        self.enabledLayerNames = enabledLayerNames
        self.enabledExtensionNames = enabledExtensionNames
    }
}

public class VkExtensionProperties {
    let extensionName: String
    let specVersion: UInt32

    init(extensionName: String,
        specVersion: Version) {
        self.extensionName = extensionName
        self.specVersion = specVersion.rawVersion
    }
}

public struct VkLayerProperties {
    let layerName: String
    let specVersion: UInt32
    let implementationVersion: UInt32
    let description: String

    init(layerName: String,
        specVersion: Version,
        implementationVersion: Version,
        description: String) {
        self.layerName = layerName
        self.specVersion = specVersion.rawVersion
        self.implementationVersion = implementationVersion.rawVersion
        self.description = description
    }
}

public class VkPhysicalDevice {
    let pointer: OpaquePointer

    init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }
}

class VkSurfaceKHR {
    let pointer: OpaquePointer

    init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }
}

enum VkPhysicalDeviceType: Int {
    case other = 0,
        integratedGpu,
        discreteGpu,
        virtualGpu,
        cpu
}

class VkPhysicalDeviceProperties: ReflectedStringConvertible {
    let apiVersion: UInt32
    let driverVersion: UInt32
    let vendorID: Int
    let deviceID: Int
    let deviceType: VkPhysicalDeviceType
    let deviceName: String
    let pipelineCacheUUID: [UInt8]
    let limits: Any? = nil // TODO: add later if needed
    let sparseProperties: Any? = nil // TODO: add later if needed

    init(
        _ apiVersion: UInt32,
        driverVersion: UInt32,
        vendorID: Int,
        deviceID: Int,
        deviceType: VkPhysicalDeviceType,
        deviceName: String,
        pipelineCacheUUID: [UInt8]) {
        self.apiVersion = apiVersion
        self.driverVersion = driverVersion
        self.vendorID = vendorID
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.deviceName = deviceName
        self.pipelineCacheUUID = pipelineCacheUUID
    }
}