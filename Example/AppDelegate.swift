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
                    tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)),

        SavedSearch(title: "My Bestest Favorites",
                    image: templated(#imageLiteral(resourceName: "heart.png")),
                    tintColor: nil),

        SavedSearch(title: "Ideas",
                    image: templated(#imageLiteral(resourceName: "lightbulb.png")),
                    tintColor: nil),

        SavedSearch(title: "Ideas",
                    image: templated(#imageLiteral(resourceName: "building.pdf")),
                    tintColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
    ]

    var theme = DanielsTheme() {
        didSet {
            fatSidebar.theme = theme
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        fatSidebar.delegate = self
        fatSidebar.theme = theme
        fatSidebar.style = .small(iconSize: 24, padding: 6)
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

    func sidebar(_ sidebar: FatSidebar, didDoubleClickItem index: Int) {

        self.sidebar(sidebar, editItem: index)
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

    var themeToggle = false {
        didSet {
            if themeToggle {
                theme.background = .init(single: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
            } else {
                theme.background = DanielsTheme.defaultBackgroundColor
            }
        }
    }

    func sidebar(_ sidebar: FatSidebar, didChangeSelection selectionIndex: Int) {

        Swift.print("Selected \(savedSearches[selectionIndex])")

        themeToggle = !themeToggle
        fatSidebar.style = {
            switch fatSidebar.style {
            case .regular: return .small(iconSize: 16, padding: 6)
            case .small: return .regular
            }
        }()
    }

    func sidebar(_ sidebar: FatSidebar, didPushItem selectionIndex: Int) {

        Swift.print("Pushed \(savedSearches[selectionIndex]) (active indices: \(sidebar.selectedItemIndexes))")
    }

    func sidebar(_ sidebar: FatSidebar, didRemoveItem index: Int) {

        self.savedSearches.remove(at: index)
        self.replaceSidebarWithModel()
    }
}
