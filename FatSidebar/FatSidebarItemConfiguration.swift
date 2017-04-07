//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

public protocol FatSidebarItemConvertible {
    var configuration: FatSidebarItemConfiguration { get }
}

public struct FatSidebarItemConfiguration: FatSidebarItemConvertible {

    public var configuration: FatSidebarItemConfiguration { return self }

    let title: String
    let image: NSImage?
    let style: FatSidebarItem.Style
    let animated: Bool
    let callback: ((FatSidebarItem) -> Void)?

    public init(
        title: String,
        image: NSImage? = nil,
        style: FatSidebarItem.Style = .regular,
        animated: Bool = false,
        callback: ((FatSidebarItem) -> Void)? = nil) {

        self.title = title
        self.image = image
        self.style = style
        self.animated = animated
        self.callback = callback
    }
}
