//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

/// Top-level module facade, acting as a composite view that scrolls.
public class FatSidebar: NSView {

    let scrollView = NSScrollView()
    let sidebarView =  FatSidebarView()//frame: NSRect(x: 0, y: 0, width: 100, height: 100))

    public var itemContextualMenu: NSMenu? {
        get { return sidebarView.itemContextualMenu }
        set { sidebarView.itemContextualMenu = newValue }
    }

    public var theme: FatSidebarTheme {
        get { return sidebarView.theme }
        set {
            sidebarView.theme = newValue

            // Update style
            scrollView.backgroundColor = theme.sidebarBackground
        }
    }

    public var animated: Bool {
        get { return sidebarView.animated }
        set { sidebarView.animated = newValue }
    }

    public convenience init() {

        self.init(frame: NSRect.zero)

        layoutSubviews()
    }

    public override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)

        layoutSubviews()
    }

    public required init?(coder: NSCoder) {

        super.init(coder: coder)

        layoutSubviews()
    }

    fileprivate func layoutSubviews() {

        scrollView.identifier = "SidebarScrollView"
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = theme.sidebarBackground
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false

        addSubview(scrollView)

        // Disable before changing `documentView`:
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.translatesAutoresizingMaskIntoConstraints = false

        let flippedView = FlippedView()
        flippedView.identifier = "FlippedDocView"
        flippedView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.addSubview(sidebarView)
        sidebarView.identifier = "SidebarView"
        sidebarView.constrainToSuperviewBounds()

        scrollView.documentView = flippedView
        flippedView.constrainToSuperviewBoundsOpenBottom()

        scrollView.constrainToSuperviewBounds()
    }

    // MARK: - Sidebar Façade

    public var itemCount: Int {
        return sidebarView.itemCount
    }

    public func item(at index: Int) -> FatSidebarItem? {

        return sidebarView.item(at: index)
    }

    public func contains(_ item: FatSidebarItem) -> Bool {

        return sidebarView.contains(item)
    }

    @discardableResult
    public func appendItem(
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        callback: @escaping (FatSidebarItem) -> Void) -> FatSidebarItem {

        return sidebarView.appendItem(title: title, image: image, style: style, callback: callback)
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(
        after item: FatSidebarItem,
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        callback: @escaping (FatSidebarItem) -> Void) -> FatSidebarItem? {

        return sidebarView.insertItem(after: item, title: title, image: image, style: style, callback: callback)
    }

    @discardableResult
    public func removeAllItems() -> [FatSidebarItem] {

        return sidebarView.removeAllItems()
    }

    @discardableResult
    public func removeItem(_ item: FatSidebarItem) -> Bool {

        return sidebarView.removeItem(item)
    }

    public var selectionMode: FatSidebarView.SelectionMode {
        get { return sidebarView.selectionMode }
        set { sidebarView.selectionMode = newValue }
    }

    /// Selects `item` if it was unselected; deselects it
    /// it if was selected. Applies to items that are part
    /// of the sidebar, only.
    ///
    /// - returns: `true` if `item` is part of the sidebar and was toggled.
    @discardableResult
    public func toggleItem(_ item: FatSidebarItem) -> Bool {

        return sidebarView.toggleItem(item)
    }

    /// - returns: `true` if `item` is part of the sidebar.
    @discardableResult
    public func selectItem(_ item: FatSidebarItem) -> Bool {

        return sidebarView.selectItem(item)
    }

    /// - returns: `true` if `item` is part of the sidebar
    ///            and was selected before, `false` otherwise.
    @discardableResult
    public func deselectItem(_ item: FatSidebarItem) -> Bool {

        return sidebarView.deselectItem(item)
    }

    /// First selected item (if any).
    ///
    /// **See** `selectedItems` for all selected items.
    public var selectedItem: FatSidebarItem? {
        return sidebarView.selectedItem
    }

    /// Collection of all selected items.
    ///
    /// **See** `selectedItem` for the first (or only) selected item.
    public var selectedItems: [FatSidebarItem] {
        return sidebarView.selectedItems
    }


}
