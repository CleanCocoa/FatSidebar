//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class DraggingView: NSView {

    private(set) var widthConstraint: NSLayoutConstraint!
    private(set) var heightConstraint: NSLayoutConstraint!

    init(source: NSView) {

        super.init(frame: NSZeroRect)

        self.translatesAutoresizingMaskIntoConstraints = false

        let image = source.imageRepresentation
        let imageView = NSImageView(frame: NSZeroRect)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false

        self.wantsLayer = true
        self.shadow = {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 0
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.7)
            shadow.shadowOffset = NSSize(width: 0, height: 0)
            return shadow
        }()

        self.addSubview(imageView)

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[img]|", options: [], metrics: nil, views: ["img" : imageView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[img]|", options: [], metrics: nil, views: ["img" : imageView]))

        self.widthConstraint = NSLayoutConstraint(
            item:       self,
            attribute:  .width,
            relatedBy:  .equal,
            toItem:     nil,
            attribute:  .width,
            multiplier: 1,
            constant:   image.size.width)
        self.heightConstraint = NSLayoutConstraint(
            item:       self,
            attribute:  .height,
            relatedBy:  .equal,
            toItem:     nil,
            attribute:  .height,
            multiplier: 1,
            constant:   image.size.height)
        self.addConstraints([
            self.widthConstraint,
            self.heightConstraint
            ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
