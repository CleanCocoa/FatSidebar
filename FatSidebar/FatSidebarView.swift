//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

/// Cusom view that displays a list of `FatSidebarItem`s.
public class FatSidebarView: NSView {

    public var theme: FatSidebarTheme = DefaultTheme() {
        didSet {
            applyThemeToItems()
        }
    }

    fileprivate func applyThemeToItems() {

        for item in items {
            item.theme = self.theme
        }
    }

    // MARK: - Content

    fileprivate var items: [FatSidebarItem] = [] {
        didSet {
            applyThemeToItems()
            layoutItems()
        }
    }

    public var itemCount: Int {
        return items.count
    }

    public func item(at index: Int) -> FatSidebarItem? {

        return items[safe: index]
    }

    public func contains(_ item: FatSidebarItem) -> Bool {

        return items.contains(item)
    }


    // MARK: Insertion

    @discardableResult
    public func appendItem(
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        callback: @escaping (FatSidebarItem) -> Void) -> FatSidebarItem {

        let item = FatSidebarItem(
            title: title,
            image: image,
            style: style,
            callback: callback)

        items.append(item)
        addSubview(item)

        return item
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(
        after item: FatSidebarItem,
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        callback: @escaping (FatSidebarItem) -> Void) -> FatSidebarItem? {

        guard let index = items.index(where: { $0 === item }) else { return nil }

        let item = FatSidebarItem(
            title: title,
            image: image,
            style: style,
            callback: callback)

        items.insert(item, at: index + 1)
        addSubview(item)

        return item
    }

    // MARK: Removal

    @discardableResult
    public func removeAllItems() -> [FatSidebarItem] {

        let removedItems = items
        items.removeAll()
        removedItems.forEach { $0.removeFromSuperview() }
        return removedItems
    }

    // MARK: Selection

    @discardableResult
    public func selectItem(_ item: FatSidebarItem) -> Bool {

        guard self.contains(item) else { return false }

        for existingItem in items {
            existingItem.isSelected = (existingItem === item)
        }

        return true
    }

    @discardableResult
    public func deselectItem(_ item: FatSidebarItem) -> Bool {

        guard self.contains(item),
            item.isSelected
            else { return false }

        item.isSelected = false

        return true
    }

    /// First selected item (if any).
    ///
    /// **See** `selectedItems` for all selected items.
    public var selectedItem: FatSidebarItem? {
        return items.first(where: { $0.isSelected })
    }

    /// Collection of all selected items.
    ///
    /// **See** `selectedItem` for the first (or only) selected item.
    public var selectedItems: [FatSidebarItem] {
        return items.filter { $0.isSelected }
    }


    // MARK: - 
    // MARK: Layout

    fileprivate var laidOutItemBox: NSRect = NSRect.zero
    public override var intrinsicContentSize: NSSize {
        return NSSize(width: 22, height: laidOutItemBox.height)
    }

    public override var frame: NSRect {
        get {
            return laidOutItemBox
        }
        set {
            super.frame = newValue // Seems to trigger notifications that make this work
            layoutItems()
        }
    }

    public override var isFlipped: Bool { return true }

    fileprivate func layoutItems() {

        let availableWidth = super.frame.width
        let itemSize = NSSize(quadratic: availableWidth)

        var allItemsFrame = NSRect.zero
        for (i, item) in items.enumerated() {

            let origin = NSPoint(
                x: 0,
                y: CGFloat(i) * itemSize.height)
            let newItemFrame = NSRect(origin: origin, size: itemSize)

            item.frame = newItemFrame

            allItemsFrame = allItemsFrame.union(newItemFrame)
        }

        laidOutItemBox = allItemsFrame

        invalidateIntrinsicContentSize()
    }

    // MARK: Drawing

    public override func draw(_ dirtyRect: NSRect) {

        let wholeFrame = self.frame

        super.draw(wholeFrame)

        drawItems()
    }

    fileprivate func drawItems() {

        for item in items {
            item.draw(item.frame)
        }
    }
}
