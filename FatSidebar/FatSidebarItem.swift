//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSLayoutConstraint {

    func prioritized(_ priority: NSLayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

public class FatSidebarItem: NSView {

    public enum Style {

        /// Displays label below image
        case regular

        /// Displays image only, label in overlay view on hover
        case small
    }

    public let style: Style
    public let callback: (FatSidebarItem) -> Void

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

    public internal(set) var theme: FatSidebarTheme = DefaultTheme() {
        didSet {
            redraw()
        }
    }

    required public init(
        title: String,
        image: NSImage? = nil,
        style: Style = .regular,
        frame: NSRect = NSRect.zero,
        callback: @escaping (FatSidebarItem) -> Void) {

        self.label = NSTextField.newWrappingLabel(title: title, controlSize: NSSmallControlSize)
        self.label.alignment = .center

        self.imageView = NSImageView()
        self.imageView.wantsLayer = true
        self.imageView.shadow = {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 0
            shadow.shadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.6881610577)
            shadow.shadowOffset = NSSize(width: 0, height: -1)
            return shadow
        }()
        self.imageView.image = image

        self.callback = callback
        self.style = style

        super.init(frame: frame)

        layoutSubviews(style: style)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    fileprivate func layoutSubviews(style: Style) {
        switch style {
        case .regular: layoutRegularSubviews()
        case .small: layoutSmallSubviews()
        }
    }

    fileprivate func layoutRegularSubviews() {

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, for: NSLayoutConstraintOrientation.vertical)
        self.addSubview(self.imageView)

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.label)

        let topSpacing = NSView()
        topSpacing.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topSpacing)
        self.addConstraints([
            // 1px width, horizontally centered
            NSLayoutConstraint(item: topSpacing, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: topSpacing, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),

            // 20% size
            NSLayoutConstraint(item: topSpacing, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0.2, constant: 1)
            ])

        let bottomSpacing = NSView()
        bottomSpacing.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomSpacing)
        self.addConstraints([
            // 1px width, horizontally centered
            NSLayoutConstraint(item: bottomSpacing, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: bottomSpacing, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),

            // 30% size
            NSLayoutConstraint(item: bottomSpacing, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0.3, constant: 1)
            ])

        let viewsDict: [String : Any] = [
            "topSpace" : topSpacing,
            "imageView" : self.imageView,
            "label" : self.label,
            "bottomSpace" : bottomSpacing
        ]

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[topSpace][imageView]-(>=4@1000)-[label]-(>=4@1000)-|",
            options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[imageView]-(0@250)-[bottomSpace]|",
            options: [], metrics: nil, views: viewsDict))

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-4-[label]-4-|",
            options: [], metrics: nil, views: viewsDict))
        self.addConstraints([
            NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: bottomSpacing, attribute: NSLayoutAttribute.centerY, multiplier: 0.95, constant: 0).prioritized(250),
            NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            ])
    }

    fileprivate func layoutSmallSubviews() {

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)

        let imageContainer = NSView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageContainer)

        let topSpacing = NSView()
        topSpacing.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(topSpacing)
        self.addConstraints([
            // 1px width, horizontally centered
            NSLayoutConstraint(item: topSpacing, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: topSpacing, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: imageContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),

            // 10% size
            NSLayoutConstraint(item: topSpacing, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: imageContainer, attribute: NSLayoutAttribute.height, multiplier: 0.1, constant: 1)
            ])

        let bottomSpacing = NSView()
        bottomSpacing.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(bottomSpacing)
        self.addConstraints([
            // 1px width, horizontally centered
            NSLayoutConstraint(item: bottomSpacing, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: bottomSpacing, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: imageContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),

            // 10% size
            NSLayoutConstraint(item: bottomSpacing, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: imageContainer, attribute: NSLayoutAttribute.height, multiplier: 0.1, constant: 1)
            ])

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.setContentCompressionResistancePriority(NSLayoutPriorityDefaultLow, for: NSLayoutConstraintOrientation.vertical)
        imageContainer.addSubview(self.imageView)

        let viewsDict: [String : Any] = [
            "topSpace" : topSpacing,
            "container" : imageContainer,
            "imageView" : self.imageView,
            "label" : self.label,
            "bottomSpace" : bottomSpacing
        ]

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[container]|",
            options: [], metrics: nil, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(
            options: [], metrics: nil, views: viewsDict))
        imageContainer.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[topSpace][imageView][bottomSpace]|",
            options: [], metrics: nil, views: viewsDict))
        imageContainer.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[imageView]|",
            options: [], metrics: nil, views: viewsDict))


        self.addConstraints([
            NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageContainer, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: imageContainer, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: imageContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            ])
    }

    // MARK: - Custom Drawing

    fileprivate func redraw() {

        self.needsDisplay = true
    }

    var borderWidth: CGFloat = 1

    public override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)

        drawBackground(dirtyRect)
        drawBorders(dirtyRect)
    }

    fileprivate func drawBackground(_ dirtyRect: NSRect) {

        theme.itemStyle.background.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
        NSRectFill(dirtyRect)
    }

    fileprivate func drawBorders(_ dirtyRect: NSRect) {

        if let leftBorderColor = theme.itemStyle.borders.left {

            let border = NSRect(x: 0, y: 0, width: borderWidth, height: dirtyRect.height)
            leftBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            NSRectFill(border)
        }

        if let topBorderColor = theme.itemStyle.borders.top {

            let border = NSRect(x: 0, y: dirtyRect.maxY - borderWidth, width: dirtyRect.width, height: borderWidth)
            topBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            NSRectFill(border)
        }

        if let rightBorderColor = theme.itemStyle.borders.right {

            let border = NSRect(x: dirtyRect.maxX - borderWidth, y: 0, width: borderWidth, height: dirtyRect.height)
            rightBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            NSRectFill(border)
        }

        if let bottomBorderColor = theme.itemStyle.borders.bottom {

            let border = NSRect(x: 0, y: dirtyRect.minY, width: dirtyRect.width, height: borderWidth)
            bottomBorderColor.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
            NSRectFill(border)
        }
    }

    // MARK: - Interaction

    public internal(set) var isSelected = false {
        didSet {
            redraw()
        }
    }

    public fileprivate(set) var isHighlighted = false {
        didSet {
            redraw()
        }
    }

    public override func mouseDown(with event: NSEvent) {

        isHighlighted = true
    }

    public override func mouseUp(with event: NSEvent) {

        isHighlighted = false

        if let sidebar = superview as? FatSidebarView {
            sidebar.selectItem(self)
        }

        sendAction()
    }

    public func sendAction() {

        callback(self)
    }


    // MARK: - Mouse Hover

    private var hoverEnabled = true

    public override func mouseEntered(with event: NSEvent) {

        guard hoverEnabled else { return }

        let floatFrame = self.superview!.convert(self.frame, to: nil)
        let float = FatSidebarItemOverlay(title: title, image: image, style: style, frame: floatFrame, callback: callback)
        float.theme = self.theme
        self.window?.contentView?.addSubview(float)
        float.animator().frame = {
            var frame = floatFrame
            frame.size.width += self.label.frame.width + 8//.width *= 2
            return frame
        }()

        NotificationCenter.default.addObserver(float, selector: #selector(FatSidebarItemOverlay.hoverDidStart), name: FatSidebarItemOverlay.hoverStarted, object: nil)

        hoverEnabled = false
        float.didExit = { [unowned self] in self.hoverEnabled = true }
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
