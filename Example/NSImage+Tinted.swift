//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSImage {
    func image(tintColor: NSColor) -> NSImage {
        if self.isTemplate == false {
            return self
        }

        let image = self.copy() as! NSImage
        image.lockFocus()

        tintColor.set()
        NSMakeRect(0, 0, image.size.width, image.size.height).fill(using: NSCompositingOperation.sourceAtop)

        image.unlockFocus()
        image.isTemplate = false

        return image
    }
}
