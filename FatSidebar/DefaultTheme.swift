//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import class Cocoa.NSColor

struct DefaultTheme: FatSidebarTheme {

    let sidebarStyle: FatSidebarStyle = DefaultSidebarStyle()
    let itemStyle: FatSidebarItemStyle = DefaultItemStyle()

    struct DefaultSidebarStyle: FatSidebarStyle {
        let background = NSColor.lightGray
    }

    struct DefaultItemStyle: FatSidebarItemStyle {
        let background = StatefulColor(
            normal: NSColor.controlColor,
            selected: NSColor.controlLightHighlightColor,
            highlighted: NSColor.lightGray)
        let bottomBorder = StatefulColor(normal: NSColor.darkGray, selected: NSColor.darkGray, highlighted: NSColor.darkGray)
    }
}
