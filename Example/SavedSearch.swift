//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import FatSidebar

struct SavedSearch {
    let title: String
    let image: NSImage
}

extension SavedSearch: CustomStringConvertible {
    var description: String {
        return self.title
    }
}

extension SavedSearch: FatSidebarItemConvertible {
    var configuration: FatSidebarItemConfiguration {
        return FatSidebarItemConfiguration(
            title: self.title,
            image: self.image,
            style: .small,
            animated: true)
    }
}
