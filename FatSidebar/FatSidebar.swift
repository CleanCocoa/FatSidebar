//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

@IBDesignable
public class FatSidebar: NSView {

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
