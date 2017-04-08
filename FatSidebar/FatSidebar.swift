//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

public protocol FatSidebarDelegate: class {
    func sidebar(_ sidebar: FatSidebar, didMoveItemFrom oldIndex: Int, to newIndex: Int)
}

public protocol FatSidebarSelectionChangeDelegate: class {
    func sidebar(_ sidebar: FatSidebar, didChangeSelection selectionIndex: Int)
}


/// Top-level module facade, acting as a composite view that scrolls.
public class FatSidebar: NSView {

    public weak var delegate: FatSidebarDelegate?
    public weak var selectionDelegate: FatSidebarSelectionChangeDelegate?

    let scrollView = NSScrollView()
    let sidebarView = FatSidebarView()

    /// Contextual menu that's activated when clicked on a sidebar item.
    public var itemContextualMenu: NSMenu? {
        get { return sidebarView.itemContextualMenu }
        set { sidebarView.itemContextualMenu = newValue }
    }

    /// Contextual menu that's acticated when clicked in outside any sidebar item.
    public var sidebarContextualMenu: NSMenu? {
        get { return scrollView.contentView.menu }
        set { scrollView.contentView.menu = newValue }
    }

    public var theme: FatSidebarTheme {
        get { return sidebarView.theme }
        set {
            sidebarView.theme = newValue

            // Update style
            scrollView.backgroundColor = theme.sidebarBackground
        }
    }

    /// Changing this value reconfigures all existing items, too.
    ///
    /// - note: New items will not inherit this value. Their configuration wins.
    public var animated: Bool {
        get { return sidebarView.animated }
        set { sidebarView.animated = newValue }
    }

    public convenience init() {
        self.init(frame: NSRect.zero)
    }

    public override init(frame frameRect: NSRect) {

        super.init(frame: frameRect)

        layoutSubviews()
        observeSidebarSelectionChanges()
    }

    public required init?(coder: NSCoder) {

        super.init(coder: coder)

        layoutSubviews()
        observeSidebarSelectionChanges()
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

    private var selectionChangeObserver: AnyObject!
    private var moveObserver: AnyObject!

    fileprivate func observeSidebarSelectionChanges() {

        let notificationCenter = NotificationCenter.default

        selectionChangeObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didSelectItemNotification,
            object: sidebarView,
            queue: nil) { [unowned self] in self.selectionDidChange($0) }

        moveObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didReorderItemNotification,
            object: sidebarView,
            queue: nil) { [unowned self] in self.itemDidMove($0) }
    }

    fileprivate func selectionDidChange(_ notification: Notification) {

        guard let index = notification.userInfo?["index"] as? Int else { return }

        selectionDelegate?.sidebar(self, didChangeSelection: index)
    }

    fileprivate func itemDidMove(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let fromIndex = userInfo["from"] as? Int,
            let toIndex = userInfo["to"] as? Int
            else { return }

        self.delegate?.sidebar(self, didMoveItemFrom: fromIndex, to: toIndex)
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
    public func appendItem(_ convertible: FatSidebarItemConvertible) -> FatSidebarItem {

        return sidebarView.appendItem(convertible)
    }

    @discardableResult
    public func appendItem(
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        callback: ((FatSidebarItem) -> Void)? = nil)
        -> FatSidebarItem
    {

        return sidebarView.appendItem(title: title, image: image, style: style, callback: callback)
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(
        _ convertible: FatSidebarItemConvertible,
        after item: FatSidebarItem)
        -> FatSidebarItem?
    {
        return sidebarView.insertItem(convertible, after: item)
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(
        after item: FatSidebarItem,
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        callback: ((FatSidebarItem) -> Void)? = nil)
        -> FatSidebarItem?
    {

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
