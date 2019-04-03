//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

@objc public protocol FatSidebarDelegate: class {
    /// Triggered after the user finishes dragging an item into a new place. 
    @objc optional func sidebar(_ sidebar: FatSidebar, didMoveItemFrom oldIndex: Int, to newIndex: Int)

    /// Triggered when `FatSidebarItem.editFatSidebarItem(_:)` is called.
    @objc optional func sidebar(_ sidebar: FatSidebar, editItem index: Int)

    /// Triggered when double-clicking an item.
    ///
    /// - note: Double clicking may be confusing for the user when you have 
    ///   the sidebar configures for toggling items.
    @objc optional func sidebar(_ sidebar: FatSidebar, didDoubleClickItem index: Int)

    /// Triggered when `FatSidebar.removeItem(_:)` is called.
    ///
    /// - note: `FatSidebarItem.removeFatSidebarItem(_:)` triggers this, too.
    @objc optional func sidebar(_ sidebar: FatSidebar, didRemoveItem index: Int)

    /// Triggered when an item is single-clicked and its status changes.
    /// Already selected items that cannot be deselected will not trigger this.
    @objc optional func sidebar(_ sidebar: FatSidebar, didChangeSelection selectionIndex: Int)

    /// Triggered when an item is single-clicked, no matter its selection state.
    @objc optional func sidebar(_ sidebar: FatSidebar, didPushItem selectionIndex: Int)

    /// Triggered when an item is single-clicked. 
    /// Deprecated in favor of `sidebar(_:didPushItem:)`.
    @available(*, message: "Prefer to use sidebar(_:didPushItem:) until toggling is better supported")
    @objc optional func sidebar(_ sidebar: FatSidebar, didToggleItem selectionIndex: Int)
}


/// Top-level module facade, acting as a composite view that scrolls.
public class FatSidebar: NSView {

    public static var sidebarScrollViewIdentifier: NSUserInterfaceItemIdentifier { return .init(rawValue: "SidebarScrollView") }
    public static var sidebarViewIdentifier: NSUserInterfaceItemIdentifier { return .init(rawValue: "SidebarView") }
    internal static var flippedDocViewIdentifier: NSUserInterfaceItemIdentifier { return .init(rawValue: "FlippedDocView") }

    public weak var delegate: FatSidebarDelegate?

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

    public var style: FatSidebarItem.Style {
        get { return sidebarView.style }
        set { sidebarView.style = newValue }
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

        scrollView.identifier = FatSidebar.sidebarScrollViewIdentifier
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = theme.sidebarBackground
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false

        addSubview(scrollView)

        // Disable before changing `documentView`:
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.translatesAutoresizingMaskIntoConstraints = false

        let flippedView = FlippedView()
        flippedView.identifier = FatSidebar.flippedDocViewIdentifier
        flippedView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.addSubview(sidebarView)
        sidebarView.identifier = FatSidebar.sidebarViewIdentifier
        sidebarView.constrainToSuperviewBounds()

        scrollView.documentView = flippedView
        flippedView.constrainToSuperviewBoundsOpenBottom()

        scrollView.constrainToSuperviewBounds()
    }

    private var selectionChangeObserver: AnyObject!
    private var toggleObserver: AnyObject!
    private var pushObserver: AnyObject!
    private var moveObserver: AnyObject!
    private var removalObserver: AnyObject!
    private var itemEditingObserver: AnyObject!
    private var doubleClickObserver: AnyObject!

    fileprivate func observeSidebarSelectionChanges() {

        let notificationCenter = NotificationCenter.default

        selectionChangeObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didSelectItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.selectionDidChange($0) }

        toggleObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didToggleItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.itemWasToggled($0) }

        pushObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didPushItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.itemWasPushed($0) }

        moveObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didReorderItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.itemDidMove($0) }

        removalObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didRemoveItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.itemWasRemoved($0) }

        itemEditingObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didStartEditingItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.itemStartsEditing($0) }

        doubleClickObserver = notificationCenter.addObserver(
            forName: FatSidebarView.didDoubleClickItemNotification,
            object: sidebarView,
            queue: nil) { [weak self] in self?.itemWasDoubleClicked($0) }
    }

    fileprivate func selectionDidChange(_ notification: Notification) {

        guard let index = notification.userInfo?["index"] as? Int else { return }

        delegate?.sidebar?(self, didChangeSelection: index)
    }

    fileprivate func itemWasPushed(_ notification: Notification) {

        guard let index = notification.userInfo?["index"] as? Int else { return }

        delegate?.sidebar?(self, didPushItem: index)
    }

    fileprivate func itemWasToggled(_ notification: Notification) {

        guard let index = notification.userInfo?["index"] as? Int else { return }

        delegate?.sidebar?(self, didToggleItem: index)
    }

    fileprivate func itemDidMove(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let fromIndex = userInfo["from"] as? Int,
            let toIndex = userInfo["to"] as? Int
            else { return }

        self.delegate?.sidebar?(self, didMoveItemFrom: fromIndex, to: toIndex)
    }

    fileprivate func itemWasRemoved(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let index = userInfo["index"] as? Int
            else { return }

        self.delegate?.sidebar?(self, didRemoveItem: index)
    }

    fileprivate func itemStartsEditing(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let index = userInfo["index"] as? Int
            else { return }

        self.delegate?.sidebar?(self, editItem: index)
    }

    fileprivate func itemWasDoubleClicked(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let index = userInfo["index"] as? Int
            else { return }

        self.delegate?.sidebar?(self, didDoubleClickItem: index)
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
        callback: ((FatSidebarItem) -> Void)? = nil)
        -> FatSidebarItem
    {

        return sidebarView.appendItem(title: title, image: image, callback: callback)
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
        callback: ((FatSidebarItem) -> Void)? = nil)
        -> FatSidebarItem?
    {

        return sidebarView.insertItem(after: item, title: title, image: image, callback: callback)
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

    /// - returns: `true` iff `index` is inside item bounds.
    @discardableResult
    public func selectItem(at index: Int) -> Bool {

        return sidebarView.selectItem(at: index)
    }

    /// - returns: `true` if `item` is part of the sidebar
    ///            and was selected before, `false` otherwise.
    @discardableResult
    public func deselectItem(_ item: FatSidebarItem) -> Bool {

        return sidebarView.deselectItem(item)
    }

    public func deselectAllItems() {

        return sidebarView.deselectAllItems()
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

    /// Collection of indexes of selected items.
    ///
    /// **See** `selectedItems` for a list of item instances.
    public var selectedItemIndexes: [Int] {
        return sidebarView.selectedItemIndexes
    }
}
