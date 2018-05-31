//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import class Cocoa.NSColor
import class Cocoa.NSView

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

public struct StatefulBackgroundColor {

    public let statefulColor: StatefulColor
    public var normal: NSColor { return statefulColor.normal }
    public var selected: NSColor { return statefulColor.selected }
    public var highlighted: NSColor { return statefulColor.highlighted }

    public let backgroundStyle: NSView.BackgroundStyle

    public init(statefulColor: StatefulColor, backgroundStyle: NSView.BackgroundStyle) {

        self.statefulColor = statefulColor
        self.backgroundStyle = backgroundStyle
    }
}

extension StatefulBackgroundColor {

    public init(normal: NSColor, selected: NSColor, highlighted: NSColor, backgroundStyle: NSView.BackgroundStyle) {

        self.init(
            statefulColor: StatefulColor(normal: normal, selected: selected, highlighted: highlighted),
            backgroundStyle: backgroundStyle)
    }

    public init(single: NSColor, backgroundStyle: NSView.BackgroundStyle) {

        self.init(
            statefulColor: StatefulColor(single: single),
            backgroundStyle: backgroundStyle)
    }

    public func color(isHighlighted: Bool = false, isSelected: Bool = false) -> NSColor {

        return statefulColor.color(isHighlighted: isHighlighted, isSelected: isSelected)
    }

    public func cgColor(isHighlighted: Bool = false, isSelected: Bool = false) -> CGColor {

        return statefulColor.cgColor(isHighlighted: isHighlighted, isSelected: isSelected)
    }
}
