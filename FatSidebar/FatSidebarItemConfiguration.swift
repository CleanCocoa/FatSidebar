//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

public protocol FatSidebarItemConvertible {
    var configuration: FatSidebarItemConfiguration { get }
}

public struct FatSidebarItemConfiguration: FatSidebarItemConvertible {

    public var configuration: FatSidebarItemConfiguration { return self }

    let title: String
    let image: NSImage?
    let shadow: NSShadow?
    let animated: Bool
    let callback: ((FatSidebarItem) -> Void)?

    public init(
        title: String,
        image: NSImage? = nil,
        shadow: NSShadow? = nil,
        animated: Bool = false,
        callback: ((FatSidebarItem) -> Void)? = nil) {

        self.title = title
        self.image = image
        self.shadow = shadow
        self.animated = animated
        self.callback = callback
    }
}
