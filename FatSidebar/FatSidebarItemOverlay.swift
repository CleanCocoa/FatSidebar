//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class FatSidebarItemOverlay: FatSidebarItem {

    static var hoverStarted: Notification.Name { return Notification.Name(rawValue: "fat sidebar hover did start") }
    var didExit: (() -> Void)?

    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let oldTrackingArea = trackingArea { self.removeTrackingArea(oldTrackingArea) }

        let newTrackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil)
        self.addTrackingArea(newTrackingArea)
        self.trackingArea = newTrackingArea
    }

    override func mouseEntered(with event: NSEvent) {

        self.window?.disableCursorRects()
        NSCursor.pointingHand().set()

        NotificationCenter.default.post(name: FatSidebarItemOverlay.hoverStarted, object: self)
    }

    func hoverDidStart(notification: Notification) {

        guard let overlay = notification.object as? FatSidebarItemOverlay else { return }
        if overlay === self { return }

        endHover()
    }

    override func mouseExited(with event: NSEvent) {

        endHover()
    }

    fileprivate func endHover() {

        self.window?.enableCursorRects()
        self.window?.resetCursorRects()

        self.removeFromSuperview()

        didExit?()
    }
}
