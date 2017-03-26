//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import FatSidebar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var fatSidebar: FatSidebar!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

//        NSMenu().addItem(withTitle: <#T##String#>, action: <#T##Selector?#>, keyEquivalent: <#T##String#>)
//        fatSidebar.addItem(title: "Inbox", callback: { _ in print("Inbox") })
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

