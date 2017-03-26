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
