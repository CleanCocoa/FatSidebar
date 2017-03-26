//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import struct Foundation.NSSize

extension NSSize {
    init(quadratic width: CGFloat) {
        self.init(width: width, height: width)
    }
}
