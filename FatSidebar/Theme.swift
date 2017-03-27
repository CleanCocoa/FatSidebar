//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import class Cocoa.NSColor

public protocol FatSidebarTheme {
    var itemStyle: FatSidebarItemStyle { get }
    var sidebarBackground: NSColor { get }
}

public protocol FatSidebarItemStyle {
    var background: StatefulColor { get }
    var borders: Borders { get }
}
