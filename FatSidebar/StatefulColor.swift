//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import class Cocoa.NSColor

public struct StatefulColor {

    public let normal: NSColor
    public let selected: NSColor
    public let highlighted: NSColor

    public init(normal: NSColor, selected: NSColor, highlighted: NSColor) {

        self.normal = normal
        self.selected = selected
        self.highlighted = highlighted
    }

    public init(single: NSColor) {

        self.normal = single
        self.selected = single
        self.highlighted = single
    }

    public func color(isHighlighted: Bool = false, isSelected: Bool = false) -> NSColor {

        if isHighlighted { return self.highlighted }
        if isSelected { return self.selected }
        return self.normal
    }

    public func cgColor(isHighlighted: Bool = false, isSelected: Bool = false) -> CGColor {

        return color(isHighlighted: isHighlighted, isSelected: isSelected).cgColor
    }
}
