//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import FatSidebar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var fatSidebar: FatSidebar!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        fatSidebar.appendItem(title: "Inbox", callback: { _ in print("Inbox") })
        fatSidebar.appendItem(title: "Sent", callback: { _ in print("Sent") })
        fatSidebar.appendItem(title: "Drafts", callback: { _ in print("Drafts") })
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

