//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import class Cocoa.NSColor

public protocol FatSidebarTheme {
    var itemStyle: FatSidebarItemStyle { get }
    var sidebarBackground: NSColor { get }
}

public protocol FatSidebarItemStyle {
    /// Replacement font for item labels. Leave as `nil` to default to system font.
    var font: NSFont? { get }
    var labelColor: StatefulColor { get }
    var background: StatefulBackgroundColor { get }
    var borders: Borders { get }
}

extension FatSidebarItemStyle {
    public var font: NSFont? { return nil }
}
