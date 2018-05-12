//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Borders {

    public static var none: Borders { return Borders(top: nil, bottom: nil, left: nil, right: nil) }
    
    public let top: StatefulColor?
    public let bottom: StatefulColor?
    public let left: StatefulColor?
    public let right: StatefulColor?

    public init(
        top: StatefulColor? = nil,
        bottom: StatefulColor? = nil,
        left: StatefulColor? = nil,
        right: StatefulColor? = nil) {

        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}
