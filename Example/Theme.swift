//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import FatSidebar
import class Cocoa.NSColor

struct OmniFocusTheme: FatSidebarTheme {

    let itemStyle: FatSidebarItemStyle = OmniFocusItemStyle()
    let sidebarBackground = OmniFocusTheme.backgroundColor

    static var selectedColor: NSColor { return #colorLiteral(red: 0.901724875, green: 0.9334430099, blue: 0.9331719875, alpha: 1) }
    static var recessedColor: NSColor { return #colorLiteral(red: 0.682291925, green: 0.6823920608, blue: 0.68227005, alpha: 1) }
    static var backgroundColor: NSColor { return #colorLiteral(red: 0.7919496894, green: 0.8197044134, blue: 0.8194655776, alpha: 1) }

    struct OmniFocusItemStyle: FatSidebarItemStyle {

        let background = StatefulColor(
            normal:      OmniFocusTheme.backgroundColor,
            selected:    OmniFocusTheme.selectedColor,
            highlighted: OmniFocusTheme.recessedColor)

        let borders = Borders(
            bottom: StatefulColor(single: OmniFocusTheme.recessedColor),
            right: StatefulColor(
                normal:      OmniFocusTheme.recessedColor,
                selected:    OmniFocusTheme.selectedColor,
                highlighted: OmniFocusTheme.recessedColor))
    }
}
