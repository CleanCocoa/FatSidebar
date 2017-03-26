//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

public class FatSidebarItem {

    public let title: String
    public let callback: (FatSidebarItem) -> Void

    public init(
        title: String,
        callback: @escaping (FatSidebarItem) -> Void) {

        self.title = title
        self.callback = callback
    }

}
