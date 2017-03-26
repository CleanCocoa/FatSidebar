//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

public class FatSidebarItem: NSView {

    public let title: String
    public let callback: (FatSidebarItem) -> Void

    public internal(set) var theme: FatSidebarTheme = DefaultTheme() {
        didSet {
            redraw()
        }
    }

    required public init(
        title: String,
        frame: NSRect = NSRect.zero,
        callback: @escaping (FatSidebarItem) -> Void) {

        self.title = title
        self.callback = callback

        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
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

        if let sidebar = superview as? FatSidebar {
            sidebar.selectItem(self)
        }

        sendAction()
    }

    public func sendAction() {

        callback(self)
    }
}
