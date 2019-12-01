//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import Foundation

#if os(macOS)

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 1024, 768),
                styleMask: [.closable, .titled],
                backing: .buffered,
                defer: false)

        window.title = "Swift running Vulkan"
        window.center()
        window.orderFrontRegardless()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate
app.run()

#elseif os(Linux)

print("Linux not supported")

#else

print("Platform not supported")

#endif
