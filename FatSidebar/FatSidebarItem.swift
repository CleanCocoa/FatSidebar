//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

public class FatSidebarItem: NSView {

    public let title: String
    public let callback: (FatSidebarItem) -> Void

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

        NSColor.blue.setFill()
        NSRectFill(dirtyRect)
    }


}
