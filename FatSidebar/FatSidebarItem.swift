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

    public func sendAction() {
        
        callback(self)
    }

    public override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)

        theme.itemStyle.background.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
        NSRectFill(dirtyRect)

        let border = NSRect(x: 0, y: dirtyRect.minY, width: dirtyRect.width, height: 1)
        theme.itemStyle.bottomBorder.color(isHighlighted: isHighlighted, isSelected: isSelected).setFill()
        NSRectFill(border)
    }

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

    fileprivate func redraw() {

        self.needsDisplay = true
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

}
