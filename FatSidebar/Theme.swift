//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import class Cocoa.NSColor

public protocol FatSidebarTheme {
    var sidebarStyle: FatSidebarStyle { get }
    var itemStyle: FatSidebarItemStyle { get }
}

public protocol FatSidebarStyle {
    var background: NSColor { get }
}

public protocol FatSidebarItemStyle {
    var background: StatefulColor { get }
    var bottomBorder: StatefulColor { get }
}
