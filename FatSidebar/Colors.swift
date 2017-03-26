//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

struct StatefulColor {

    let normal: NSColor
    let selected: NSColor
    let highlighted: NSColor

    init(normal: NSColor, selected: NSColor, highlighted: NSColor) {

        self.normal = normal
        self.selected = selected
        self.highlighted = highlighted
    }

    init(single: NSColor) {

        self.normal = single
        self.selected = single
        self.highlighted = single
    }

    func color(isHighlighted: Bool = false, isSelected: Bool = false) -> NSColor {

        if isHighlighted { return self.highlighted }
        if isSelected { return self.selected }
        return self.normal
    }

    func cgColor(isHighlighted: Bool = false, isSelected: Bool = false) -> CGColor {

        return color(isHighlighted: isHighlighted, isSelected: isSelected).cgColor
    }
}

struct Colors {
    struct Sidebar {
        static let background = NSColor.darkGray
    }

    struct Item {
        static let background = StatefulColor(normal: NSColor.gray, selected: NSColor.darkGray, highlighted: NSColor.lightGray)
        static let bottomBorder = StatefulColor(normal: NSColor.darkGray, selected: NSColor.darkGray, highlighted: NSColor.darkGray)
    }
}
