//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

extension Collection {

    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
