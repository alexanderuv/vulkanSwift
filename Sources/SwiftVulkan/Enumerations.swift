
//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

// FLAGS ========

public struct CompositeAlphaFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue 
    }

    public static let none = CompositeAlphaFlags(rawValue: 0)
    public static let opaque = CompositeAlphaFlags(rawValue: 1 << 0)
    public static let preMultiplied = CompositeAlphaFlags(rawValue: 1 << 1)
    public static let postMultiplied = CompositeAlphaFlags(rawValue: 1 << 2)
    public static let inherit = CompositeAlphaFlags(rawValue: 1 << 3)

    var vulkan: VkCompositeAlphaFlagBitsKHR {
        return VkCompositeAlphaFlagBitsKHR(self.rawValue)
    }
}

public struct ImageAspectFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue 
    }

    public static let color = ImageAspectFlags(rawValue: 1 << 0)
    public static let depth = ImageAspectFlags(rawValue: 1 << 1)
    public static let stencil = ImageAspectFlags(rawValue: 1 << 2)
    public static let metadata = ImageAspectFlags(rawValue: 1 << 3)
    public static let plane0 = ImageAspectFlags(rawValue: 1 << 4)
    public static let plane1 = ImageAspectFlags(rawValue: 1 << 5)
    public static let plane2 = ImageAspectFlags(rawValue: 1 << 6)
    public static let memoryPlane0 = ImageAspectFlags(rawValue: 1 << 7)
    public static let memoryPlane1 = ImageAspectFlags(rawValue: 1 << 8)
    public static let memoryPlane2 = ImageAspectFlags(rawValue: 1 << 9)
    public static let memoryPlane3 = ImageAspectFlags(rawValue: 1 << 10)

    var vulkan: VkImageAspectFlags {
        return VkImageAspectFlags(self.rawValue)
    }
}

public struct ImageUsageFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue 
    }

    public static let transferSrc = ImageUsageFlags(rawValue: 1 << 0)
    public static let transferDst = ImageUsageFlags(rawValue: 1 << 1)
    public static let sampled = ImageUsageFlags(rawValue: 1 << 2)
    public static let storage = ImageUsageFlags(rawValue: 1 << 3)
    public static let colorAttachment = ImageUsageFlags(rawValue: 1 << 4)
    public static let depthStencilAttachment = ImageUsageFlags(rawValue: 1 << 5)
    public static let transientAttachment = ImageUsageFlags(rawValue: 1 << 6)
    public static let inputAttachment = ImageUsageFlags(rawValue: 1 << 7)
    public static let shadingRateImage = ImageUsageFlags(rawValue: 1 << 8)

    var vulkan: VkImageUsageFlagBits {
        return VkImageUsageFlagBits(self.rawValue)
    }
}

public struct SampleCountFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue 
    }

    public static let none = ImageUsageFlags(rawValue: 0)
    public static let _1bit = ImageUsageFlags(rawValue: 0x00000001)
    public static let _2bit = ImageUsageFlags(rawValue: 0x00000001)
    public static let _4bit = ImageUsageFlags(rawValue: 0x00000001)
    public static let _8bit = ImageUsageFlags(rawValue: 0x00000001)
    public static let _16bit = ImageUsageFlags(rawValue: 0x00000001)
    public static let _32bit = ImageUsageFlags(rawValue: 0x00000001)
    public static let _64bit = ImageUsageFlags(rawValue: 0x00000001)

    var vulkan: VkSampleCountFlagBits {
        return VkSampleCountFlagBits(self.rawValue)
    }
}

public struct SurfaceTransformFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue 
    }

    public static let none = SurfaceTransformFlags(rawValue: 0)
    public static let identity = SurfaceTransformFlags(rawValue: 1 << 0)
    public static let rotate90 = SurfaceTransformFlags(rawValue: 1 << 1)
    public static let rotate180 = SurfaceTransformFlags(rawValue: 1 << 2)
    public static let rotate270 = SurfaceTransformFlags(rawValue: 1 << 3)
    public static let horizontalMirror = SurfaceTransformFlags(rawValue: 1 << 4)
    public static let horizontalMirrorRotate90 = SurfaceTransformFlags(rawValue: 1 << 5)
    public static let horizontalMirrorRotate180 = SurfaceTransformFlags(rawValue: 1 << 6)
    public static let horizontalMirrorRotate270 = SurfaceTransformFlags(rawValue: 1 << 7)
    public static let inherit = SurfaceTransformFlags(rawValue: 1 << 8)

    var vulkan: VkSurfaceTransformFlagBitsKHR {
        return VkSurfaceTransformFlagBitsKHR(self.rawValue)
    }
}

// ============


// ENUMS ========

public enum CommandBufferLevel: UInt32 {
    case primary = 0,
    secondary = 1
}

public enum ComponentSwizzle: UInt32 {
    case identity = 0,
        zero = 1,
        one = 2,
        r = 3,
        g = 4,
        b = 5,
        a = 6

    var vulkan: VkComponentSwizzle {
        return VkComponentSwizzle(self.rawValue)
    }
}

public enum ColorSpace: UInt32 {
    case SRGB_NONLINEAR_KHR = 0,
    DISPLAY_P3_NONLINEAR_EXT = 1000104001,
    EXTENDED_SRGB_LINEAR_EXT = 1000104002,
    DCI_P3_LINEAR_EXT = 1000104003,
    DCI_P3_NONLINEAR_EXT = 1000104004,
    BT709_LINEAR_EXT = 1000104005,
    BT709_NONLINEAR_EXT = 1000104006,
    BT2020_LINEAR_EXT = 1000104007,
    HDR10_ST2084_EXT = 1000104008,
    DOLBYVISION_EXT = 1000104009,
    HDR10_HLG_EXT = 1000104010,
    ADOBERGB_LINEAR_EXT = 1000104011,
    ADOBERGB_NONLINEAR_EXT = 1000104012,
    PASS_THROUGH_EXT = 1000104013,
    EXTENDED_SRGB_NONLINEAR_EXT = 1000104014

    var vulkan: VkColorSpaceKHR {
        return VkColorSpaceKHR(self.rawValue)
    }
}

public enum Format: UInt32 {
    case UNDEFINED = 0,
    R4G4_UNORM_PACK8 = 1,
    R4G4B4A4_UNORM_PACK16 = 2,
    B4G4R4A4_UNORM_PACK16 = 3,
    R5G6B5_UNORM_PACK16 = 4,
    B5G6R5_UNORM_PACK16 = 5,
    R5G5B5A1_UNORM_PACK16 = 6,
    B5G5R5A1_UNORM_PACK16 = 7,
    A1R5G5B5_UNORM_PACK16 = 8,
    R8_UNORM = 9,
    R8_SNORM = 10,
    R8_USCALED = 11,
    R8_SSCALED = 12,
    R8_UINT = 13,
    R8_SINT = 14,
    R8_SRGB = 15,
    R8G8_UNORM = 16,
    R8G8_SNORM = 17,
    R8G8_USCALED = 18,
    R8G8_SSCALED = 19,
    R8G8_UINT = 20,
    R8G8_SINT = 21,
    R8G8_SRGB = 22,
    R8G8B8_UNORM = 23,
    R8G8B8_SNORM = 24,
    R8G8B8_USCALED = 25,
    R8G8B8_SSCALED = 26,
    R8G8B8_UINT = 27,
    R8G8B8_SINT = 28,
    R8G8B8_SRGB = 29,
    B8G8R8_UNORM = 30,
    B8G8R8_SNORM = 31,
    B8G8R8_USCALED = 32,
    B8G8R8_SSCALED = 33,
    B8G8R8_UINT = 34,
    B8G8R8_SINT = 35,
    B8G8R8_SRGB = 36,
    R8G8B8A8_UNORM = 37,
    R8G8B8A8_SNORM = 38,
    R8G8B8A8_USCALED = 39,
    R8G8B8A8_SSCALED = 40,
    R8G8B8A8_UINT = 41,
    R8G8B8A8_SINT = 42,
    R8G8B8A8_SRGB = 43,
    B8G8R8A8_UNORM = 44,
    B8G8R8A8_SNORM = 45,
    B8G8R8A8_USCALED = 46,
    B8G8R8A8_SSCALED = 47,
    B8G8R8A8_UINT = 48,
    B8G8R8A8_SINT = 49,
    B8G8R8A8_SRGB = 50,
    A8B8G8R8_UNORM_PACK32 = 51,
    A8B8G8R8_SNORM_PACK32 = 52,
    A8B8G8R8_USCALED_PACK32 = 53,
    A8B8G8R8_SSCALED_PACK32 = 54,
    A8B8G8R8_UINT_PACK32 = 55,
    A8B8G8R8_SINT_PACK32 = 56,
    A8B8G8R8_SRGB_PACK32 = 57,
    A2R10G10B10_UNORM_PACK32 = 58,
    A2R10G10B10_SNORM_PACK32 = 59,
    A2R10G10B10_USCALED_PACK32 = 60,
    A2R10G10B10_SSCALED_PACK32 = 61,
    A2R10G10B10_UINT_PACK32 = 62,
    A2R10G10B10_SINT_PACK32 = 63,
    A2B10G10R10_UNORM_PACK32 = 64,
    A2B10G10R10_SNORM_PACK32 = 65,
    A2B10G10R10_USCALED_PACK32 = 66,
    A2B10G10R10_SSCALED_PACK32 = 67,
    A2B10G10R10_UINT_PACK32 = 68,
    A2B10G10R10_SINT_PACK32 = 69,
    R16_UNORM = 70,
    R16_SNORM = 71,
    R16_USCALED = 72,
    R16_SSCALED = 73,
    R16_UINT = 74,
    R16_SINT = 75,
    R16_SFLOAT = 76,
    R16G16_UNORM = 77,
    R16G16_SNORM = 78,
    R16G16_USCALED = 79,
    R16G16_SSCALED = 80,
    R16G16_UINT = 81,
    R16G16_SINT = 82,
    R16G16_SFLOAT = 83,
    R16G16B16_UNORM = 84,
    R16G16B16_SNORM = 85,
    R16G16B16_USCALED = 86,
    R16G16B16_SSCALED = 87,
    R16G16B16_UINT = 88,
    R16G16B16_SINT = 89,
    R16G16B16_SFLOAT = 90,
    R16G16B16A16_UNORM = 91,
    R16G16B16A16_SNORM = 92,
    R16G16B16A16_USCALED = 93,
    R16G16B16A16_SSCALED = 94,
    R16G16B16A16_UINT = 95,
    R16G16B16A16_SINT = 96,
    R16G16B16A16_SFLOAT = 97,
    R32_UINT = 98,
    R32_SINT = 99,
    R32_SFLOAT = 100,
    R32G32_UINT = 101,
    R32G32_SINT = 102,
    R32G32_SFLOAT = 103,
    R32G32B32_UINT = 104,
    R32G32B32_SINT = 105,
    R32G32B32_SFLOAT = 106,
    R32G32B32A32_UINT = 107,
    R32G32B32A32_SINT = 108,
    R32G32B32A32_SFLOAT = 109,
    R64_UINT = 110,
    R64_SINT = 111,
    R64_SFLOAT = 112,
    R64G64_UINT = 113,
    R64G64_SINT = 114,
    R64G64_SFLOAT = 115,
    R64G64B64_UINT = 116,
    R64G64B64_SINT = 117,
    R64G64B64_SFLOAT = 118,
    R64G64B64A64_UINT = 119,
    R64G64B64A64_SINT = 120,
    R64G64B64A64_SFLOAT = 121,
    B10G11R11_UFLOAT_PACK32 = 122,
    E5B9G9R9_UFLOAT_PACK32 = 123,
    D16_UNORM = 124,
    X8_D24_UNORM_PACK32 = 125,
    D32_SFLOAT = 126,
    S8_UINT = 127,
    D16_UNORM_S8_UINT = 128,
    D24_UNORM_S8_UINT = 129,
    D32_SFLOAT_S8_UINT = 130,
    BC1_RGB_UNORM_BLOCK = 131,
    BC1_RGB_SRGB_BLOCK = 132,
    BC1_RGBA_UNORM_BLOCK = 133,
    BC1_RGBA_SRGB_BLOCK = 134,
    BC2_UNORM_BLOCK = 135,
    BC2_SRGB_BLOCK = 136,
    BC3_UNORM_BLOCK = 137,
    BC3_SRGB_BLOCK = 138,
    BC4_UNORM_BLOCK = 139,
    BC4_SNORM_BLOCK = 140,
    BC5_UNORM_BLOCK = 141,
    BC5_SNORM_BLOCK = 142,
    BC6H_UFLOAT_BLOCK = 143,
    BC6H_SFLOAT_BLOCK = 144,
    BC7_UNORM_BLOCK = 145,
    BC7_SRGB_BLOCK = 146,
    ETC2_R8G8B8_UNORM_BLOCK = 147,
    ETC2_R8G8B8_SRGB_BLOCK = 148,
    ETC2_R8G8B8A1_UNORM_BLOCK = 149,
    ETC2_R8G8B8A1_SRGB_BLOCK = 150,
    ETC2_R8G8B8A8_UNORM_BLOCK = 151,
    ETC2_R8G8B8A8_SRGB_BLOCK = 152,
    EAC_R11_UNORM_BLOCK = 153,
    EAC_R11_SNORM_BLOCK = 154,
    EAC_R11G11_UNORM_BLOCK = 155,
    EAC_R11G11_SNORM_BLOCK = 156,
    ASTC_4x4_UNORM_BLOCK = 157,
    ASTC_4x4_SRGB_BLOCK = 158,
    ASTC_5x4_UNORM_BLOCK = 159,
    ASTC_5x4_SRGB_BLOCK = 160,
    ASTC_5x5_UNORM_BLOCK = 161,
    ASTC_5x5_SRGB_BLOCK = 162,
    ASTC_6x5_UNORM_BLOCK = 163,
    ASTC_6x5_SRGB_BLOCK = 164,
    ASTC_6x6_UNORM_BLOCK = 165,
    ASTC_6x6_SRGB_BLOCK = 166,
    ASTC_8x5_UNORM_BLOCK = 167,
    ASTC_8x5_SRGB_BLOCK = 168,
    ASTC_8x6_UNORM_BLOCK = 169,
    ASTC_8x6_SRGB_BLOCK = 170,
    ASTC_8x8_UNORM_BLOCK = 171,
    ASTC_8x8_SRGB_BLOCK = 172,
    ASTC_10x5_UNORM_BLOCK = 173,
    ASTC_10x5_SRGB_BLOCK = 174,
    ASTC_10x6_UNORM_BLOCK = 175,
    ASTC_10x6_SRGB_BLOCK = 176,
    ASTC_10x8_UNORM_BLOCK = 177,
    ASTC_10x8_SRGB_BLOCK = 178,
    ASTC_10x10_UNORM_BLOCK = 179,
    ASTC_10x10_SRGB_BLOCK = 180,
    ASTC_12x10_UNORM_BLOCK = 181,
    ASTC_12x10_SRGB_BLOCK = 182,
    ASTC_12x12_UNORM_BLOCK = 183,
    ASTC_12x12_SRGB_BLOCK = 184,
    G8B8G8R8_422_UNORM = 1000156000,
    B8G8R8G8_422_UNORM = 1000156001,
    G8_B8_R8_3PLANE_420_UNORM = 1000156002,
    G8_B8R8_2PLANE_420_UNORM = 1000156003,
    G8_B8_R8_3PLANE_422_UNORM = 1000156004,
    G8_B8R8_2PLANE_422_UNORM = 1000156005,
    G8_B8_R8_3PLANE_444_UNORM = 1000156006,
    R10X6_UNORM_PACK16 = 1000156007,
    R10X6G10X6_UNORM_2PACK16 = 1000156008,
    R10X6G10X6B10X6A10X6_UNORM_4PACK16 = 1000156009,
    G10X6B10X6G10X6R10X6_422_UNORM_4PACK16 = 1000156010,
    B10X6G10X6R10X6G10X6_422_UNORM_4PACK16 = 1000156011,
    G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16 = 1000156012,
    G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16 = 1000156013,
    G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16 = 1000156014,
    G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16 = 1000156015,
    G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16 = 1000156016,
    R12X4_UNORM_PACK16 = 1000156017,
    R12X4G12X4_UNORM_2PACK16 = 1000156018,
    R12X4G12X4B12X4A12X4_UNORM_4PACK16 = 1000156019,
    G12X4B12X4G12X4R12X4_422_UNORM_4PACK16 = 1000156020,
    B12X4G12X4R12X4G12X4_422_UNORM_4PACK16 = 1000156021,
    G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16 = 1000156022,
    G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16 = 1000156023,
    G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16 = 1000156024,
    G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16 = 1000156025,
    G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16 = 1000156026,
    G16B16G16R16_422_UNORM = 1000156027,
    B16G16R16G16_422_UNORM = 1000156028,
    G16_B16_R16_3PLANE_420_UNORM = 1000156029,
    G16_B16R16_2PLANE_420_UNORM = 1000156030,
    G16_B16_R16_3PLANE_422_UNORM = 1000156031,
    G16_B16R16_2PLANE_422_UNORM = 1000156032,
    G16_B16_R16_3PLANE_444_UNORM = 1000156033,
    PVRTC1_2BPP_UNORM_BLOCK_IMG = 1000054000,
    PVRTC1_4BPP_UNORM_BLOCK_IMG = 1000054001,
    PVRTC2_2BPP_UNORM_BLOCK_IMG = 1000054002,
    PVRTC2_4BPP_UNORM_BLOCK_IMG = 1000054003,
    PVRTC1_2BPP_SRGB_BLOCK_IMG = 1000054004,
    PVRTC1_4BPP_SRGB_BLOCK_IMG = 1000054005,
    PVRTC2_2BPP_SRGB_BLOCK_IMG = 1000054006,
    PVRTC2_4BPP_SRGB_BLOCK_IMG = 1000054007
    static let G8B8G8R8_422_UNORM_KHR = G8B8G8R8_422_UNORM
    static let B8G8R8G8_422_UNORM_KHR = B8G8R8G8_422_UNORM
    static let G8_B8_R8_3PLANE_420_UNORM_KHR = G8_B8_R8_3PLANE_420_UNORM
    static let G8_B8R8_2PLANE_420_UNORM_KHR = G8_B8R8_2PLANE_420_UNORM
    static let G8_B8_R8_3PLANE_422_UNORM_KHR = G8_B8_R8_3PLANE_422_UNORM
    static let G8_B8R8_2PLANE_422_UNORM_KHR = G8_B8R8_2PLANE_422_UNORM
    static let G8_B8_R8_3PLANE_444_UNORM_KHR = G8_B8_R8_3PLANE_444_UNORM
    static let R10X6_UNORM_PACK16_KHR = R10X6_UNORM_PACK16
    static let R10X6G10X6_UNORM_2PACK16_KHR = R10X6G10X6_UNORM_2PACK16
    static let R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR = R10X6G10X6B10X6A10X6_UNORM_4PACK16
    static let G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR = G10X6B10X6G10X6R10X6_422_UNORM_4PACK16
    static let B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR = B10X6G10X6R10X6G10X6_422_UNORM_4PACK16
    static let G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR = G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16
    static let G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR = G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16
    static let G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR = G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16
    static let G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR = G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16
    static let G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR = G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16
    static let R12X4_UNORM_PACK16_KHR = R12X4_UNORM_PACK16
    static let R12X4G12X4_UNORM_2PACK16_KHR = R12X4G12X4_UNORM_2PACK16
    static let R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR = R12X4G12X4B12X4A12X4_UNORM_4PACK16
    static let G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR = G12X4B12X4G12X4R12X4_422_UNORM_4PACK16
    static let B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR = B12X4G12X4R12X4G12X4_422_UNORM_4PACK16
    static let G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR = G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16
    static let G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR = G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16
    static let G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR = G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16
    static let G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR = G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16
    static let G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR = G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16
    static let G16B16G16R16_422_UNORM_KHR = G16B16G16R16_422_UNORM
    static let B16G16R16G16_422_UNORM_KHR = B16G16R16G16_422_UNORM
    static let G16_B16_R16_3PLANE_420_UNORM_KHR = G16_B16_R16_3PLANE_420_UNORM
    static let G16_B16R16_2PLANE_420_UNORM_KHR = G16_B16R16_2PLANE_420_UNORM
    static let G16_B16_R16_3PLANE_422_UNORM_KHR = G16_B16_R16_3PLANE_422_UNORM
    static let G16_B16R16_2PLANE_422_UNORM_KHR = G16_B16R16_2PLANE_422_UNORM
    static let G16_B16_R16_3PLANE_444_UNORM_KHR = G16_B16_R16_3PLANE_444_UNORM

    var vulkan: VkFormat {
        return VkFormat(self.rawValue)
    }
}

public enum ImageLayout: UInt32 {
    case undefined = 0,
    general = 1,
    colorAttachmentOptimal = 2,
    depthStencilAttachmentOptimal = 3,
    depthStencilReadOnlyOptimal = 4,
    shaderReadOnlyOptimal = 5,
    transferSrcOptimal = 6,
    transferDstOptimal = 7,
    preinitialized = 8,
    depthReadOnlyStencilAttachmentOptimal = 1000117000,
    depthAttachmentStencilReadOnlyOptimal = 1000117001,
    presentSrc = 1000001002,
    shaderPresent = 1000111000,
    shadingRateOptimal = 1000164003,
    fragmentDensityMapOptimal = 1000218000

    var vulkan: VkImageLayout {
        return VkImageLayout(self.rawValue)
    }
}

public enum ImageTiling: UInt32 {
    case optimal = 0,
    linear = 1,
    drmFormatModifier = 1000158000

    var vulkan: VkImageTiling {
        return VkImageTiling(self.rawValue)
    }
}

public enum ImageType: UInt32 {
    case type1D = 0,
    type2D = 1,
    type3D = 2

    var vulkan: VkImageType {
        return VkImageType(self.rawValue)
    }
}

public enum ImageViewType: UInt32 {
    case    type1D = 0,
            type2D = 1,
            type3D = 2,
            typeCube = 3,
            type1DArray = 4,
            type2DArray = 5,
            typeCubeArray = 6

    var vulkan: VkImageViewType { 
        return VkImageViewType(self.rawValue)
    }
}

public enum PhysicalDeviceType: UInt32 {
    case other = 0,
        integratedGpu,
        discreteGpu,
        virtualGpu,
        cpu
}

public enum PresentMode: UInt32 {
    case immediate = 0,
    mailbox = 1,
    fifo = 2,
    fifoRelaxed = 3,
    sharedDemandRefresh = 1000111000,
    sharedContinuousRefresh = 1000111001

    var vulkan: VkPresentModeKHR {
        return VkPresentModeKHR(self.rawValue)
    }
}

public enum Result: Int32, Error {
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

public enum SharingMode: UInt32 {
    case exclusive = 0,
    concurrent = 1

    var vulkan: VkSharingMode {
        return VkSharingMode(self.rawValue)
    }
}

// ============
