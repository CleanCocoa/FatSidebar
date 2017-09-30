//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSView {

    var draggingView: DraggingView {

        return DraggingView(source: self)
    }

    var imageRepresentation: NSImage {

        let wasHidden = self.isHidden
        let wantedLayer = self.wantsLayer

        self.isHidden = false
        self.wantsLayer = true

        let image = NSImage(size: self.bounds.size)
        image.lockFocus()
        let ctx = NSGraphicsContext.current?.cgContext
        self.layer?.render(in: ctx!)
        image.unlockFocus()

        self.wantsLayer = wantedLayer
        self.isHidden = wasHidden

        return image
    }
}
