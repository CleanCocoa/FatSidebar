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
            style: .small,
            animated: true)
    }
}
