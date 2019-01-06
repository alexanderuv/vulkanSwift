
public enum PhysicalDeviceType: Int {
    case other = 0,
        integratedGpu,
        discreteGpu,
        virtualGpu,
        cpu
}

public enum Result: Int32 {
    case success = 0,
    notReady = 1,
    timeout = 2,
    eventSet = 3,
    eventReset = 4,
    incomplete = 5,
    errorOutOfHostMemory = -1,
    errorOutOfDeviceMemory = -2,
    errorInitializationFailed = -3,
    errorDeviceLost = -4,
    errorMemoryMapFailed = -5,
    errorLayerNotPresent = -6,
    errorExtensionNotPresent = -7,
    errorFeatureNotPresent = -8,
    errorIncompatibleDriver = -9,
    errorTooManyObjects = -10,
    errorFormatNotSupported = -11,
    errorFragmentedPool = -12,
    errorOutOfPoolMemory = -1000069000,
    errorInvalidExternalHandle = -1000072003,
    errorSurfaceLostKhr = -1000000000,
    errorNativeWindowInUseKhr = -1000000001,
    suboptimalKhr = 1000001003,
    errorOutOfDateKhr = -1000001004,
    errorIncompatibleDisplayKhr = -1000003001,
    errorValidationFailedExt = -1000011001,
    errorInvalidShaderNv = -1000012000,
    errorInvalidDrmFormatModifierPlaneLayoutExt = -1000158000,
    errorFragmentationExt = -1000161000,
    errorNotPermittedExt = -1000174001

    // synonyms
    static let errorOutOfPoolMemoryKhr = errorOutOfPoolMemory
    static let errorInvalidExternalHandleKhr = errorInvalidExternalHandle
}
