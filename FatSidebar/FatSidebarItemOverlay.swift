//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class FatSidebarItemOverlay: FatSidebarItem {

    static var hoverStarted: Notification.Name { return Notification.Name(rawValue: "fat sidebar hover did start") }
    var overlayFinished: (() -> Void)?

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

        if let overlay = notification.object as? FatSidebarItemOverlay,
            overlay === self { return }

        endHover()
    }

    override func mouseExited(with event: NSEvent) {

        endHover()
    }

    fileprivate func endHover() {

        self.window?.enableCursorRects()
        self.window?.resetCursorRects()

        self.removeFromSuperview()

        overlayFinished?()
    }

    var scrolledOffset: CGFloat?

    func didScroll(_ notification: Notification) {

        guard let scrollView = notification.object as? NSScrollView,
            let scrolledOffset = scrolledOffset
            else { return }

        let diff = scrolledOffset - scrollView.scrolledY

        self.frame.origin.y -= diff

        self.scrolledOffset = scrollView.scrolledY
    }
}
