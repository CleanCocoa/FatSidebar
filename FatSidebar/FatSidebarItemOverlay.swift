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
    var didExit = false
    var overlayFinished: (() -> Void)?

    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let oldTrackingArea = self.trackingArea { self.removeTrackingArea(oldTrackingArea) }

        guard !didExit else { return }

        createAndAssignTrackingArea()
        fireEnteredOrExitedWithInitialMouseCoordinates()
    }

    fileprivate func createAndAssignTrackingArea() {

        let newTrackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil)
        self.addTrackingArea(newTrackingArea)
        self.trackingArea = newTrackingArea
    }

    fileprivate func fireEnteredOrExitedWithInitialMouseCoordinates() {

        guard let absoluteMousePoint = self.window?.mouseLocationOutsideOfEventStream else { return }

        let mousePoint = self.convert(absoluteMousePoint, from: nil)

        if NSPointInRect(mousePoint, self.bounds) {
            mouseDidEnter()
        } else {
            mouseDidExit()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        mouseDidEnter()
    }

    /// - note: Use when event is not available, as in `updateTrackingRect`.
    fileprivate func mouseDidEnter() {

        self.window?.disableCursorRects()
        NSCursor.pointingHand.set()

        NotificationCenter.default.post(name: FatSidebarItemOverlay.hoverStarted, object: self)
    }

    @objc func hoverDidStart(notification: Notification) {

        if let overlay = notification.object as? FatSidebarItemOverlay,
            overlay === self { return }

        endHover()
    }

    override func mouseExited(with event: NSEvent) {
        mouseDidExit()
    }

    /// - note: Use when event is not available, as in `updateTrackingRect`.
    fileprivate func mouseDidExit() {

        didExit = true // Call before endHover to prevend updateTrackingRect loop
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
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResizeWindow(_:)),
            name: NSWindow.didResizeNotification,
            object: scrollView.window)
    }

    fileprivate var windowHeight: CGFloat?

    @objc func didResizeWindow(_ notification: Notification) {

        guard let window = notification.object as? NSWindow,
            let oldHeight = windowHeight
            else { return }

        let newHeight = window.frame.height
        let diff = oldHeight - newHeight
        self.frame.origin.y -= diff
        self.windowHeight = newHeight
    }

    fileprivate var scrolledOffset: CGFloat?

    @objc func didScroll(_ notification: Notification) {

        guard let contentView = notification.object as? NSView,
            let scrollView = contentView.superview as? NSScrollView,
            let scrolledOffset = scrolledOffset
            else { return }

        let diff = scrolledOffset - scrollView.scrolledY
        self.frame.origin.y -= diff
        self.scrolledOffset = scrollView.scrolledY
    }
}
