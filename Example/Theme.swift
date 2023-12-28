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

        let font: NSFont? = NSFont.systemFont(ofSize: 14)
        let labelColor = StatefulColor(single: NSColor.controlTextColor)

        let background = StatefulBackgroundColor(
            normal:      OmniFocusTheme.backgroundColor,
            selected:    OmniFocusTheme.selectedColor,
            highlighted: OmniFocusTheme.recessedColor,
            backgroundStyle: .light)

        let borders = Borders(
            bottom: StatefulColor(single: OmniFocusTheme.recessedColor),
            right: StatefulColor(
                normal:      OmniFocusTheme.recessedColor,
                selected:    OmniFocusTheme.selectedColor,
                highlighted: OmniFocusTheme.recessedColor))
    }
}

struct DanielsTheme: FatSidebarTheme {

    static var defaultBackgroundColor: StatefulColor {
        return StatefulColor(
            normal: #colorLiteral(red: 0.03137254902, green: 0.3137254902, blue: 0.6666666667, alpha: 1),
            selected: #colorLiteral(red: 0.03137254902, green: 0.3137254902, blue: 0.6666666667, alpha: 1),
            highlighted: #colorLiteral(red: 0.08235294118, green: 0.2941176471, blue: 0.5607843137, alpha: 1))
    }

    private var _itemStyle: ItemStyle
    var itemStyle: FatSidebarItemStyle { return _itemStyle }

    var background: StatefulColor {
        didSet {
            _itemStyle.background = statefulBackgroundColor
        }
    }
    var statefulBackgroundColor: StatefulBackgroundColor {
        return StatefulBackgroundColor(statefulColor: background, backgroundStyle: .dark)
    }

    var sidebarBackground: NSColor { return background.normal }

    init(background: StatefulColor, fontSize: CGFloat) {
        self.background = background
        self._itemStyle = ItemStyle(
            background: StatefulBackgroundColor(statefulColor: background, backgroundStyle: .dark),
            fontSize: fontSize)
    }

    init() {
        self.init(background: DanielsTheme.defaultBackgroundColor, fontSize: 14.0)
    }

    struct ItemStyle: FatSidebarItemStyle {

        let labelColor = StatefulColor(single: NSColor.green)
        let borders = Borders.none

        var font: NSFont?
        var background: StatefulBackgroundColor

        init(background: StatefulBackgroundColor, fontSize: CGFloat) {
            self.background = background
            self.font = NSFont.systemFont(ofSize: fontSize)
        }
    }
}
