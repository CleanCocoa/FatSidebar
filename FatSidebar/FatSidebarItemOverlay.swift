//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class FatSidebarItemOverlay: FatSidebarItem {

    weak var base: FatSidebarItem!

    override func mouseHeld(_ timer: Timer) {

        self.animator().alphaValue = 0.0
        base.mouseHeld(timer)
    }

    // MARK: - Hovering 

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


    // MARK: - Scrolling

    func setupScrollSyncing(scrollView: NSScrollView) {

        self.scrolledOffset = scrollView.scrolledY
        self.windowHeight = scrollView.window?.frame.height

        scrollView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScroll(_:)),
            name: .NSViewBoundsDidChange,
            object: scrollView.contentView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResizeWindow(_:)),
            name: .NSWindowDidResize,
            object: scrollView.window)
    }

    fileprivate var windowHeight: CGFloat?

    func didResizeWindow(_ notification: Notification) {

        guard let window = notification.object as? NSWindow,
            let oldHeight = windowHeight
            else { return }

        let newHeight = window.frame.height
        let diff = oldHeight - newHeight
        self.frame.origin.y -= diff
        self.windowHeight = newHeight
    }

    fileprivate var scrolledOffset: CGFloat?

    func didScroll(_ notification: Notification) {

        guard let contentView = notification.object as? NSView,
            let scrollView = contentView.superview as? NSScrollView,
            let scrolledOffset = scrolledOffset
            else { return }

        let diff = scrolledOffset - scrollView.scrolledY
        self.frame.origin.y -= diff
        self.scrolledOffset = scrollView.scrolledY
    }
}
