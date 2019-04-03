//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

extension Array where Element : Equatable {

    mutating func move(_ element: Array.Element, by distance: Int) {

        guard let removeIndex = self.firstIndex(of: element) else { return }

        let insertIndex = self.index(removeIndex, offsetBy: distance)
        self.remove(at: removeIndex)
        self.insert(element, at: insertIndex)
    }
}
