//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import FatSidebar

struct SavedSearch {
    let title: String
    let image: NSImage
    let tintColor: NSColor?

    init(title: String, image: NSImage, tintColor: NSColor? = nil) {

        self.title = title
        self.image = image
        self.tintColor = tintColor
    }
}

extension SavedSearch: CustomStringConvertible {
    var description: String {
        return self.title
    }
}

let sharedShadow: NSShadow = {
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 0
    shadow.shadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.6881610577)
    shadow.shadowOffset = NSSize(width: 0, height: -1)
    return shadow
}()

extension SavedSearch: FatSidebarItemConvertible {
    var configuration: FatSidebarItemConfiguration {

        let image: NSImage = {

            guard let tintColor = self.tintColor
                else { return self.image }

            return self.image.image(tintColor: tintColor)
        }()

        return FatSidebarItemConfiguration(
            title: self.title,
            image: image,
            shadow: sharedShadow,
            style: .small(iconSize: 24, padding: 6),
            animated: true)
    }
}
