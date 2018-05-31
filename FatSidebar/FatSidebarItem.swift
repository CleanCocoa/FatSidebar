//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSLayoutConstraint {

    func prioritized(_ priority: Float) -> NSLayoutConstraint {
        self.priority = NSLayoutConstraint.Priority(rawValue: priority)
        return self
    }
}

extension NSScrollView {
    var scrolledY: CGFloat { return self.contentView.bounds.origin.y }
}

public class FatSidebarItem: NSView {

    public enum Style {

        /// Displays label below image
        case regular

        /// Displays image only, label in overlay view on hover
        case small(iconSize: CGFloat, padding: CGFloat)

        public var supportsHovering: Bool {
            switch self {
            case .regular: return false
            case .small: return true
            }
        }
    }

    public let callback: ((FatSidebarItem) -> Void)?
    public var selectionHandler: ((FatSidebarItem) -> Void)?
    public var editHandler: ((FatSidebarItem) -> Void)?
    public var doubleClickHandler: ((FatSidebarItem) -> Void)?
    public var animated: Bool

    let label: NSTextField
    public var title: String {
        set { label.stringValue = newValue }
        get { return label.stringValue }
    }
    let imageView: NSImageView
    public var image: NSImage? {
        set { imageView.image = newValue }
        get { return imageView.image }
    }

    public internal(set) var style: Style {
        didSet {
            layoutSubviews(style: style)
            redraw()
        }
    }

    public internal(set) var theme: FatSidebarTheme = DefaultTheme() {
        didSet {
            adjustLabelFont()
            redraw()
        }
    }

    convenience public init(
        title: String,
        image: NSImage? = nil,
        shadow: NSShadow? = nil,
        animated: Bool = false,
        style: Style = .regular,
        callback: ((FatSidebarItem) -> Void)?) {

        let configuration = FatSidebarItemConfiguration(
            title: title,
            image: image,
            shadow: shadow,
            animated: animated,
            callback: callback)

        self.init(configuration: configuration, style: style)
    }

    required public init(configuration: FatSidebarItemConfiguration, style: Style) {

        self.style = style

        self.label = NSTextField.newWrappingLabel(
            title: configuration.title,
            controlSize: .small)
        self.label.alignment = .center

        self.imageView = NSImageView()
        self.imageView.wantsLayer = true
        self.imageView.shadow = configuration.shadow
        self.imageView.image = configuration.image
        self.imageView.imageScaling = .scaleProportionallyUpOrDown

        self.animated = configuration.animated

        self.callback = configuration.callback

        super.init(frame: NSZeroRect)

        self.translatesAutoresizingMaskIntoConstraints = false
        layoutSubviews(style: style)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    fileprivate func layoutSubviews(style: Style) {

        resetSubviews()

        switch style {
        case .regular: layoutRegularSubviews()
        case let .small(iconSize: iconSize, padding: padding):
            layoutSmallSubviews(iconSize: iconSize, padding: padding)
        }
    }

    private var topSpacing: NSView?
    private var bottomSpacing: NSView?
    private var imageContainer: NSView?
    private var styleLayoutConstraints: [NSLayoutConstraint] = []

    private func resetSubviews() {

        self.removeConstraints(styleLayoutConstraints)
        styleLayoutConstraints = []

        imageContainer?.removeFromSuperview()
        imageView.removeFromSuperview()
        label.removeFromSuperview()
        topSpacing?.removeFromSuperview()
        bottomSpacing?.removeFromSuperview()
    }

    fileprivate func layoutRegularSubviews() {

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.addSubview(self.imageView)

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.label)

        let topSpacing = NSView()
        topSpacing.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topSpacing)
        self.topSpacing = topSpacing
        let topSpacingConstraints = [
            // 1px width, horizontally centered
            NSLayoutConstraint(item: topSpacing, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: topSpacing, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),

            // 20% size
            NSLayoutConstraint(item: topSpacing, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.2, constant: 1)
            ]
        self.styleLayoutConstraints.append(contentsOf: topSpacingConstraints)
        self.addConstraints(topSpacingConstraints)

        let bottomSpacing = NSView()
        bottomSpacing.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomSpacing)
        self.bottomSpacing = bottomSpacing
        let bottomSpacingConstraints = [
            // 1px width, horizontally centered
            NSLayoutConstraint(item: bottomSpacing, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: bottomSpacing, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),

            // 30% size
            NSLayoutConstraint(item: bottomSpacing, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.3, constant: 1)
            ]
        self.styleLayoutConstraints.append(contentsOf: bottomSpacingConstraints)
        self.addConstraints(bottomSpacingConstraints)

        let viewsDict: [String : Any] = [
            "topSpace" : topSpacing,
            "imageView" : self.imageView,
            "label" : self.label,
            "bottomSpace" : bottomSpacing
        ]

        let mainConstraints = [
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[topSpace][imageView][bottomSpace]|",
                options: [], metrics: nil, views: viewsDict),
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[label]-(>=4@1000)-|",
                options: [], metrics: nil, views: viewsDict),
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[label]-(4@250)-|",
                options: [], metrics: nil, views: viewsDict),
            ]
            .flattened()
            .appending(NSLayoutConstraint(item: self.label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            .appending(NSLayoutConstraint(item: self.label, attribute: .centerY, relatedBy: .equal, toItem: bottomSpacing, attribute: .centerY, multiplier: 0.95, constant: 0).prioritized(250))
            .appending(NSLayoutConstraint(item: self.imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraints(mainConstraints)
        self.styleLayoutConstraints.append(contentsOf: mainConstraints)

        label.setNeedsDisplay()
    }

    public override func layout() {

        if case .regular = self.style {
            self.label.preferredMaxLayoutWidth = NSWidth(self.label.alignmentRect(forFrame: self.frame))
        }
        
        super.layout()
    }

    fileprivate func layoutSmallSubviews(iconSize: CGFloat, padding: CGFloat) {

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)

        let imageContainer = NSView()
        imageContainer.identifier = .init(rawValue: "imageContainer")
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageContainer)
        self.imageContainer = imageContainer

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageContainer.addSubview(self.imageView)

        let viewsDict: [String : Any] = [
            "container" : imageContainer,
            "imageView" : self.imageView,
            "label" : self.label,
        ]

        let mainConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[container]|",
                options: [], metrics: nil, views: viewsDict),
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[container]-1-[label]", // Open to the right
                options: [], metrics: nil, views: viewsDict),
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(\(padding))-[imageView]-(\(padding))-|",
                options: [], metrics: nil, views: viewsDict)
            ]
            .flattened()
            .appending(NSLayoutConstraint(item: self.label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            .appending(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: iconSize))
            .appending(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1, constant: 0))

        self.addConstraints(mainConstraints)
        self.styleLayoutConstraints.append(contentsOf: mainConstraints)

        imageContainer.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(\(padding))-[imageView]-(\(padding))-|",
            options: [], metrics: nil, views: viewsDict))
    }

    // MARK: - Custom Drawing

    fileprivate func adjustLabelFont() {

        self.label.font = theme.itemStyle.font ?? label.fittingSystemFont()
    }

    fileprivate func redraw() {

        self.needsDisplay = true

        self.label.textColor = theme.itemStyle.labelColor
            .color(isHighlighted: self.isHighlighted, isSelected: self.isSelected)
        self.label.cell?.backgroundStyle = theme.itemStyle.background.backgroundStyle
    }

    var borderWidth: CGFloat = 1

    public override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)

        drawBackground(dirtyRect)
        drawBorders(dirtyRect)
    }

    fileprivate func drawBackground(_ dirtyRect: NSRect) {

        theme.itemStyle.background.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
        dirtyRect.fill()
    }

    fileprivate func drawBorders(_ dirtyRect: NSRect) {

        if let leftBorderColor = theme.itemStyle.borders.left {

            let border = NSRect(x: 0, y: 0, width: borderWidth, height: dirtyRect.height)
            leftBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            border.fill()
        }

        if let topBorderColor = theme.itemStyle.borders.top {

            let border = NSRect(x: 0, y: dirtyRect.maxY - borderWidth, width: dirtyRect.width, height: borderWidth)
            topBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            border.fill()
        }

        if let rightBorderColor = theme.itemStyle.borders.right {

            let border = NSRect(x: dirtyRect.maxX - borderWidth, y: 0, width: borderWidth, height: dirtyRect.height)
            rightBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            border.fill()
        }

        if let bottomBorderColor = theme.itemStyle.borders.bottom {

            let border = NSRect(x: 0, y: dirtyRect.minY, width: dirtyRect.width, height: borderWidth)
            bottomBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            border.fill()
        }
    }

    // MARK: - Interaction

    public internal(set) var isSelected = false {
        didSet {
            redraw()
            overlay?.isSelected = isSelected
        }
    }

    public fileprivate(set) var isHighlighted = false {
        didSet {
            redraw()
        }
    }

    // MARK: Dragging

    /// Shared flag to make sure that when some item is being clicked, moving
    /// the mouse does not trigger hover effects on adjacent items.
    private static var startedDragging = false

    struct Dragging {
        static let threshold: TimeInterval = 0.4
        let initialEvent: NSEvent
        var dragTimer: Timer?
        var isDragging = false
    }

    var dragging: Dragging?

    public override func mouseDown(with event: NSEvent) {

        isHighlighted = true

        let dragTimer = Timer.scheduledTimer(
            timeInterval: Dragging.threshold,
            target: self,
            selector: #selector(mouseHeld(_:)),
            userInfo: event,
            repeats: false)

        self.dragging = Dragging(
            initialEvent: event,
            dragTimer: dragTimer,
            isDragging: false)

        FatSidebarItem.startedDragging = true
    }

    @objc func mouseHeld(_ timer: Timer) {

        self.dragging?.isDragging = true

        guard let event = timer.userInfo as? NSEvent,
            let target = superview as? DragViewContainer
            else  { return }

        target.reorder(subview: self, event: event)
    }

    public override func mouseUp(with event: NSEvent) {

        FatSidebarItem.startedDragging = false

        isHighlighted = false

        defer {
            dragging?.dragTimer?.invalidate()
            dragging = nil
        }

        if event.clickCount == 2 {
            doubleClickHandler?(self)
            return
        }

        guard let dragging = dragging,
            !dragging.isDragging
            else { return }

        selectionHandler?(self)
        sendAction()
    }

    public func sendAction() {

        callback?(self)
    }

    /// - note: Can be used as action from Interface Builder.
    @IBAction public func editFatSidebarItem(_ sender: Any?) {

        editHandler?(self)
    }

    /// - note: Can be used as action from Interface Builder.
    @IBAction public func removeFatSidebarItem(_ sender: Any?) {

        // Forward event from here because if the sidebar
        // would receive the NSMenuItem action, it wouldn't
        // be able to figure out the affected item.
        guard let sidebar = self.superview as? FatSidebarView else {
            preconditionFailure("Expected superview to be FatSidebarView")
        }

        sidebar.removeItem(self)
    }


    // MARK: - Mouse Hover

    private var overlay: FatSidebarItemOverlay? {
        didSet {

            guard overlay == nil,
                let oldOverlay = oldValue
                else { return }

            NotificationCenter.default.removeObserver(oldOverlay)
        }
    }

    private var isDisplayingOverlay: Bool { return overlay != nil }

    public override func mouseEntered(with event: NSEvent) {

        if FatSidebarItem.startedDragging { return }
        if isDisplayingOverlay { return }

        NotificationCenter.default.post(
            name: FatSidebarItemOverlay.hoverStarted,
            object: self)

        guard style.supportsHovering else { return }

        showHoverItem()
    }

    private func showHoverItem() {

        guard let superview = self.superview,
            let windowContentView = self.window?.contentView
            else { return }

        self.overlay = {

            let overlayFrame = superview.convert(self.frame, to: nil)
            let overlay = FatSidebarItemOverlay(
                title: self.title,
                image: self.image,
                style: self.style,
                callback: self.callback)
            overlay.wantsLayer = true
            overlay.layer?.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            overlay.frame = overlayFrame
            overlay.base = self
            overlay.theme = self.theme
            overlay.isSelected = self.isSelected
            overlay.translatesAutoresizingMaskIntoConstraints = true

            overlay.editHandler = { [weak self] _ in
                guard let item = self else { return }
                item.editHandler?(item)
            }
            overlay.doubleClickHandler = { [weak self] _ in
                guard let item = self else { return }
                item.doubleClickHandler?(item)
            }
            overlay.selectionHandler = { [weak self] _ in
                guard let item = self else { return }
                item.selectionHandler?(item)
            }
            overlay.overlayFinished = { [weak self] in self?.overlay = nil }

            NotificationCenter.default.addObserver(
                overlay,
                selector: #selector(FatSidebarItemOverlay.hoverDidStart),
                name: FatSidebarItemOverlay.hoverStarted,
                object: nil)

            if let scrollView = enclosingScrollView {
                overlay.setupScrollSyncing(scrollView: scrollView)
            }

            windowContentView.addSubview(
                overlay,
                positioned: .above,
                relativeTo: windowContentView.subviews.first ?? self)
            (animated
                ? overlay.animator()
                : overlay)
                .frame = {
                    // Proportional right spacing looks best in all circumstances:
                    let rightPadding: CGFloat = self.frame.height * 0.1

                    var frame = overlayFrame
                    frame.size.width += self.label.frame.width + rightPadding
                    return frame
            }()

            return overlay
        }()
    }

    private var trackingArea: NSTrackingArea?

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let oldTrackingArea = trackingArea { self.removeTrackingArea(oldTrackingArea) }

        let newTrackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow],
            owner: self,
            userInfo: nil)
        self.addTrackingArea(newTrackingArea)
        self.trackingArea = newTrackingArea
    }

}

extension Array {
    func appending(_ newElement: Element) -> [Element] {
        var result = self
        result.append(newElement)
        return result
    }
}

extension Array where Element: Sequence {
    func flattened() -> [Element.Element] {
        return self.flatMap { $0 }
    }
}
