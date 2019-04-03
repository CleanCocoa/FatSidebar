//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

func addAspectRatioConstraint(view: NSView) {

    view.addConstraint(NSLayoutConstraint(
        item: view, attribute: .height, relatedBy: .equal,
        toItem: view, attribute: .width,
        multiplier: 1, constant: 0))
}

/// Cusom view that displays a list of `FatSidebarItem`s.
public class FatSidebarView: NSView, DragViewContainer {

    /// Fired when an item was clicked, no matter its selection state.
    static let didPushItemNotification = Notification.Name("FatSidebarView_didPushItemNotification")
    /// Fired when an item was selected or deselected through toggling.
    /// - note: Does not replace `didSelectItemNotification` or `didDeselectItemNotification`.
    static let didToggleItemNotification = Notification.Name("FatSidebarView_didToggleItemNotification")
    static let didSelectItemNotification = Notification.Name("FatSidebarView_didSelectItemNotification")
    static let didDeselectItemNotification = Notification.Name("FatSidebarView_didDeselectItemNotification")

    static let didReorderItemNotification = Notification.Name("FatSidebarView_didReorderItemNotification")
    static let didRemoveItemNotification = Notification.Name("FatSidebarView_didRemoveItemNotification")

    static let didStartEditingItemNotification = Notification.Name("FatSidebarView_didStartEditingItemNotification")
    static let didDoubleClickItemNotification = Notification.Name("FatSidebarView_didDoubleClickItemNotification")

    public var style: FatSidebarItem.Style = .regular {
        didSet {
            applyStyleToItems()
        }
    }

    fileprivate func applyStyleToItems() {

        for item in items {
            item.style = self.style
        }
    }

    public var theme: FatSidebarTheme = DefaultTheme() {
        didSet {
            applyThemeToItems()
        }
    }

    public var animated: Bool = false {
        didSet {
            items.forEach { $0.animated = animated }
        }
    }

    fileprivate func applyThemeToItems() {

        for item in items {
            item.theme = self.theme
        }
    }

    var itemContextualMenu: NSMenu? {
        didSet {
            items.forEach { $0.menu = itemContextualMenu }
        }
    }

    // MARK: - Content

    fileprivate var items: [FatSidebarItem] = [] {
        didSet {
            applyThemeToItems()
            layoutItems()
        }
    }

    fileprivate func layoutItems() {
        layoutSubviews(self.subviews)
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

    fileprivate func fatSidebarItem(configuration: FatSidebarItemConfiguration) -> FatSidebarItem {

        let item = FatSidebarItem(configuration: configuration, style: style)
        item.menu = self.itemContextualMenu
        item.selectionHandler = { [unowned self] in self.itemSelected($0) }
        item.doubleClickHandler = { [unowned self] in self.itemDoubleClicked($0) }
        item.editHandler = { [unowned self] in self.itemBeginsEditing($0) }

        return item
    }

    @discardableResult
    public func appendItem(
        title: String,
        image: NSImage? = nil,
        shadow: NSShadow? = nil,
        callback: ((FatSidebarItem) -> Void)? = nil)
        -> FatSidebarItem
    {

        let configuration = FatSidebarItemConfiguration(
            title: title,
            image: image,
            shadow: shadow,
            callback: callback)

        return self.appendItem(configuration)
    }

    @discardableResult
    public func appendItem(_ convertible: FatSidebarItemConvertible) -> FatSidebarItem {

        let configuration = convertible.configuration
        let item = fatSidebarItem(configuration: configuration)
        addAspectRatioConstraint(view: item)
        addSubview(item)
        items.append(item)

        return item
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(
        after item: FatSidebarItem,
        title: String,
        image: NSImage? = nil,
        shadow: NSShadow? = nil,
        callback: ((FatSidebarItem) -> Void)? = nil)
        -> FatSidebarItem?
    {
        let configuration = FatSidebarItemConfiguration(
            title: title,
            image: image,
            shadow: shadow,
            callback: callback)

        return self.insertItem(configuration, after: item)
    }

    /// - returns: `nil` if `item` is not part of this sidebar, an instance of `FatSidebarItem` otherwise.
    @discardableResult
    public func insertItem(
        _ convertible: FatSidebarItemConvertible,
        after item: FatSidebarItem)
        -> FatSidebarItem?
    {

        guard let index = items.firstIndex(where: { $0 === item }) else { return nil }

        let configuration = convertible.configuration
        let item = fatSidebarItem(configuration: configuration)
        addAspectRatioConstraint(view: item)
        addSubview(item)
        items.insert(item, at: index + 1)

        return item
    }

    /// Internal selection callback that performs user-facing selection
    /// depending on `selectionMode`.
    fileprivate func itemSelected(_ item: FatSidebarItem) {

        switch selectionMode {
        case .selectOne:
            self.selectItem(item)
            self.pushItem(item)

        case .toggleOne,
             .toggleMultiple:
            self.toggleItem(item)
            self.pushItem(item)

        case .push:
            self.pushItem(item)
        }
    }

    fileprivate func itemDoubleClicked(_ item: FatSidebarItem) {

        guard let index = self.items.firstIndex(of: item) else { return }

        NotificationCenter.default.post(
            name: FatSidebarView.didDoubleClickItemNotification,
            object: self,
            userInfo: ["index" : index])
    }

    fileprivate func itemBeginsEditing(_ item: FatSidebarItem) {

        guard let index = self.items.firstIndex(of: item) else { return }

        NotificationCenter.default.post(
            name: FatSidebarView.didStartEditingItemNotification,
            object: self,
            userInfo: ["index" : index])
    }
    
    // MARK: Removal

    @discardableResult
    public func removeAllItems() -> [FatSidebarItem] {

        let removedItems = items
        items.removeAll()
        removedItems.forEach { $0.removeFromSuperview() }
        return removedItems
    }

    @discardableResult
    public func removeItem(_ item: FatSidebarItem) -> Bool {

        guard let index = items.firstIndex(of: item)
            else { return false }

        item.removeFromSuperview()
        items.remove(at: index)

        NotificationCenter.default.post(
            name: FatSidebarView.didRemoveItemNotification,
            object: self,
            userInfo: ["index" : index])

        return true
    }


    // MARK: - 
    // MARK: Dragging

    public func didDrag(view: NSView, from: Int, to: Int) {

        guard let item = view as? FatSidebarItem else {
            preconditionFailure("Expected `didDrag` to receive FatSidebarItem")
        }

        let distance = to - from
        self.items.move(item, by: distance)

        NotificationCenter.default.post(
            name: FatSidebarView.didReorderItemNotification,
            object: self,
            userInfo: ["from" : from, "to" : to])
    }

    // MARK: -
    // MARK: Selection

    public enum SelectionMode {

        // Trigger action but don't select. 
        //
        // Like NSButton's "Push Momentarily".
        case push

        /// Clicking an item selects it.
        /// Clicking multiple times on the same item doesn't alter the selection.
        ///
        /// Behaves like a radio button.
        case selectOne

        /// Clicking an item first selects it; clicking again
        /// deselects it.
        ///
        /// Behaves like a radio button that allows empty selection.
        case toggleOne

        /// Behaves like a check box.
        case toggleMultiple

        var allowsMultiple: Bool {
            switch self {
            case .toggleMultiple: return true
            default: return false
            }
        }
    }

    public var selectionMode: SelectionMode = .selectOne

    /// Selects `item` if it was unselected; deselects it
    /// it if was selected. Applies to items that are part
    /// of the sidebar, only.
    ///
    /// - note: Deselects other selected items.
    /// - returns: `true` if `item` is part of the sidebar and was toggled.
    @discardableResult
    public func toggleItem(_ item: FatSidebarItem) -> Bool {

        guard let index = items.firstIndex(of: item) else { return false }

        if !selectionMode.allowsMultiple {
            selectedItems
                .filter { $0 !== item }
                .forEach { self.deselectItem($0) }
        }

        if item.isSelected { deselectItem(item) }
        else { selectItem(item) }

        NotificationCenter.default.post(
            name: FatSidebarView.didToggleItemNotification,
            object: self,
            userInfo: ["index" : index])

        return true
    }

    @discardableResult
    public func pushItem(_ item: FatSidebarItem) -> Bool {

        guard let index = items.firstIndex(of: item) else { return false }

        NotificationCenter.default.post(
            name: FatSidebarView.didPushItemNotification,
            object: self,
            userInfo: ["index" : index])

        return true
    }

    /// - note: Deselects other selected items.
    /// - returns: `true` if `item` is part of the sidebar.
    @discardableResult
    public func selectItem(_ item: FatSidebarItem) -> Bool {

        guard let index = self.items.firstIndex(of: item)
            else { return false }

        return selectItem(at: index)
    }

    /// - returns: `true` iff `index` is inside item bounds.
    @discardableResult
    public func selectItem(at index: Int) -> Bool {

        guard items.endIndex > index else { return false }

        if !selectionMode.allowsMultiple {
            deselectAllItems()
        }

        items[index].isSelected = true

        NotificationCenter.default.post(
            name: FatSidebarView.didSelectItemNotification,
            object: self,
            userInfo: ["index" : index])

        return true
    }

    /// - returns: `true` if `item` is part of the sidebar
    ///            and was selected before, `false` otherwise.
    @discardableResult
    public func deselectItem(_ item: FatSidebarItem) -> Bool {

        guard let index = self.items.firstIndex(of: item),
            item.isSelected
            else { return false }

        item.isSelected = false

        NotificationCenter.default.post(
            name: FatSidebarView.didDeselectItemNotification,
            object: self,
            userInfo: ["index" : index])

        return true
    }

    public func deselectAllItems() {

        selectedItems.forEach { self.deselectItem($0) }
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

    /// Collection of indexes of selected items.
    ///
    /// **See** `selectedItems` for a list of item instances.
    public var selectedItemIndexes: [Int] {
        return items.enumerated()
            .filter { $0.element.isSelected }
            .map { $0.offset }
    }


    // MARK: -
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
