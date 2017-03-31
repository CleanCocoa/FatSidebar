//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import FatSidebar

func templated(_ image: NSImage) -> NSImage {
    let result = image.copy() as! NSImage
    result.isTemplate = true
    return result
}

extension NSImage {
    func image(tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }

        let image = self.copy() as! NSImage
        image.lockFocus()

        tintColor.set()
        NSRectFillUsingOperation(NSMakeRect(0, 0, image.size.width, image.size.height), NSCompositingOperation.sourceAtop)

        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var addItemController: AddItemController!
    @IBOutlet weak var itemContextualMenu: NSMenu!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var fatSidebar: FatSidebar!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        fatSidebar.theme = OmniFocusTheme()
        fatSidebar.selectionMode = .toggle
        fatSidebar.animated = true
        fatSidebar.itemContextualMenu = itemContextualMenu
        fatSidebar.appendItem(
            title: "Inbox",
            image: templated(#imageLiteral(resourceName: "inbox.png")).image(tintColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)),
            style: .small,
            callback: { _ in print("Inbox") })
        fatSidebar.appendItem(
            title: "My Bestest Favorites",
            image: templated(#imageLiteral(resourceName: "heart.png")),
            style: .small,
            callback: { _ in print("Favs") })
        fatSidebar.appendItem(
            title: "Ideas",
            image: templated(#imageLiteral(resourceName: "lightbulb.png")),
            style: .regular,
            callback: { _ in print("Ideas") })
    }

    @IBAction func addSidebarItem(_ sender: Any?) {

        addItemController.showSheet(in: self.window) { newItem in

            guard let newItem = newItem else { return }

            self.appendNewItem(newItem)
        }
    }

    private func appendNewItem(_ newItem: NewItem) {

        fatSidebar.appendItem(
            title: newItem.title,
            image: newItem.image,
            style: .small,
            callback: { print("New: \($0)") })
    }

}
