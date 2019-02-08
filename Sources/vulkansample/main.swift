//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import Foundation
import SwiftSDL2

// initialize SDL2
initializeSwiftSDL2()

do {
    let s = try VulkanSample()
    if let sample = s {
        try sample.initialize()
        sample.run()
    }
} catch {
    print("Error running sample \(error)")
}


deinitializeSwiftSDL2()
