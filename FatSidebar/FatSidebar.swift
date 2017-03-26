//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

@IBDesignable
public class FatSidebar: NSView {

    // MARK: - Content

    fileprivate var items: [FatSidebarItem] = []

    public var itemCount: Int {
        return items.count
    }

    @discardableResult
    public func appendItem(title: String, callback: @escaping (FatSidebarItem) -> Void) -> FatSidebarItem {

        let item = FatSidebarItem(
            title: title,
            callback: callback)

        items.append(item)

        return item
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(after item: FatSidebarItem, title: String, callback: @escaping (FatSidebarItem) -> Void) -> FatSidebarItem? {

        guard let index = items.index(where: { $0 === item }) else { return nil }

        let item = FatSidebarItem(
            title: title,
            callback: callback)
        items.insert(item, at: index + 1)

        return item
    }

    public func item(at index: Int) -> FatSidebarItem? {

        return items[safe: index]
    }

    @discardableResult
    public func removeAllItems() -> [FatSidebarItem] {

        let removedItems = items
        items.removeAll()
        return removedItems
    }

    // MARK: - Drawing

    @IBInspectable var backgroundColor: NSColor?

    public override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)

        drawBackground(dirtyRect)
    }

    fileprivate func drawBackground(_ dirtyRect: NSRect) {

        guard let backgroundColor = backgroundColor else { return }

        backgroundColor.set()
        NSRectFill(dirtyRect)
    }
}
