
#include <stdint.h>

typedef uint32_t VkBool32;

typedef union ClearColorValue {
    float       float32[4];
    int32_t     int32[4];
    uint32_t    uint32[4];
} ClearColorValue;

typedef struct ClearDepthStencilValue {
    float       depth;
    uint32_t    stencil;
} ClearDepthStencilValue;

typedef union ClearValue {
    ClearColorValue           color;
    ClearDepthStencilValue    depthStencil;
} ClearValue;

typedef union PerformanceValueDataINTEL {
    uint32_t       value32;
    uint64_t       value64;
    float          valueFloat;
    VkBool32       valueBool;
    const char*    valueString;
} PerformanceValueDataINTEL;

typedef union PipelineExecutableStatisticValueKHR {
    VkBool32    b32;
    int64_t     i64;
    uint64_t    u64;
    double      f64;
} PipelineExecutableStatisticValueKHR;