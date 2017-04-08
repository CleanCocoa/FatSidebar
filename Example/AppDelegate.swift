//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import FatSidebar

func templated(_ image: NSImage) -> NSImage {
    let result = image.copy() as! NSImage
    result.isTemplate = true
    return result
}

extension SavedSearch {
    static var defaultImage: NSImage {
        return templated(#imageLiteral(resourceName: "layers.png"))
    }

    init(fromNewItem newItem: NewItem) {
        self.init(title: newItem.title, image: newItem.image ?? SavedSearch.defaultImage)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, FatSidebarDelegate, FatSidebarSelectionChangeDelegate {

    @IBOutlet weak var addItemController: AddItemController!
    @IBOutlet weak var itemContextualMenu: NSMenu!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var fatSidebar: FatSidebar!

    var savedSearches: [SavedSearch] = [
        SavedSearch(title: "Inbox",
                    image: templated(#imageLiteral(resourceName: "inbox.png")).image(tintColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))),

        SavedSearch(title: "My Bestest Favorites",
                    image: templated(#imageLiteral(resourceName: "heart.png"))),

        SavedSearch(title: "Ideas",
                    image: templated(#imageLiteral(resourceName: "lightbulb.png")))
    ]

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        fatSidebar.delegate = self
        fatSidebar.selectionDelegate = self
        fatSidebar.theme = OmniFocusTheme()
        fatSidebar.selectionMode = .toggle

        fatSidebar.sidebarContextualMenu = itemContextualMenu
        fatSidebar.itemContextualMenu = itemContextualMenu

        for savedSearch in savedSearches {
            fatSidebar.appendItem(savedSearch)
        }
    }

    @IBAction func addSidebarItem(_ sender: Any?) {

        addItemController.showSheet(in: self.window) { newItem in

            guard let newItem = newItem else { return }

            self.appendNewItem(newItem)
        }
    }

    private func appendNewItem(_ newItem: NewItem) {

        let savedSearch = SavedSearch(fromNewItem: newItem)
        fatSidebar.appendItem(savedSearch)
        savedSearches.append(savedSearch)
    }

    func sidebar(_ sidebar: FatSidebar, didMoveItemFrom oldIndex: Int, to newIndex: Int) {

        guard oldIndex != newIndex else { return }

        let item = savedSearches.remove(at: oldIndex)
        savedSearches.insert(item, at: newIndex)
    }

    func sidebar(_ sidebar: FatSidebar, didChangeSelection selectionIndex: Int) {

        Swift.print("Selected \(savedSearches[selectionIndex])")
    }
}
