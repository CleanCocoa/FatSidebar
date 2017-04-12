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
        self.init(
            title: newItem.title,
            image: newItem.image ?? SavedSearch.defaultImage,
            tintColor: newItem.tintColor)
    }

    var newItem: NewItem {
        return NewItem(title: self.title, image: self.image, tintColor: self.tintColor)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, FatSidebarDelegate {

    @IBOutlet weak var addItemController: AddItemController!
    @IBOutlet weak var itemContextualMenu: NSMenu!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var fatSidebar: FatSidebar!

    var savedSearches: [SavedSearch] = [
        SavedSearch(title: "Inbox",
                    image: templated(#imageLiteral(resourceName: "inbox.png")),
                    tintColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)),

        SavedSearch(title: "My Bestest Favorites",
                    image: templated(#imageLiteral(resourceName: "heart.png")),
                    tintColor: nil),

        SavedSearch(title: "Ideas",
                    image: templated(#imageLiteral(resourceName: "lightbulb.png")),
                    tintColor: nil)
    ]

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        fatSidebar.delegate = self
        fatSidebar.theme = OmniFocusTheme()
        fatSidebar.selectionMode = .toggleOne

        fatSidebar.sidebarContextualMenu = itemContextualMenu
        fatSidebar.itemContextualMenu = itemContextualMenu

        replaceSidebarWithModel()
    }

    fileprivate func replaceSidebarWithModel() {

        fatSidebar.removeAllItems()

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
        savedSearches.append(savedSearch)
        self.replaceSidebarWithModel()
    }

    func sidebar(_ sidebar: FatSidebar, didMoveItemFrom oldIndex: Int, to newIndex: Int) {

        guard oldIndex != newIndex else { return }

        let item = savedSearches.remove(at: oldIndex)
        savedSearches.insert(item, at: newIndex)
    }

    func sidebar(_ sidebar: FatSidebar, editItem index: Int) {

        let oldValues = savedSearches[index].newItem
        addItemController.showSheet(in: self.window, initialValues: oldValues) { item in

            guard let item = item else { return }

            let savedSearch = SavedSearch(fromNewItem: item)
            self.savedSearches.remove(at: index)
            self.savedSearches.insert(savedSearch, at: index)

            self.replaceSidebarWithModel()
        }
    }

    func sidebar(_ sidebar: FatSidebar, didChangeSelection selectionIndex: Int) {

        Swift.print("Selected \(savedSearches[selectionIndex])")
    }

    func sidebar(_ sidebar: FatSidebar, didToggleItem selectionIndex: Int) {

        Swift.print("Toggled \(savedSearches[selectionIndex]) (active indices: \(sidebar.selectedItemIndexes))")
    }

    func sidebar(_ sidebar: FatSidebar, didRemoveItem index: Int) {

        self.savedSearches.remove(at: index)
        self.replaceSidebarWithModel()
    }
}
