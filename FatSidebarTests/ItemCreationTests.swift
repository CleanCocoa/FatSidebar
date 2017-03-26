//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import FatSidebar

extension Int {
    func times(_ f: () -> Void) {
        for _ in 0..<self {
            f()
        }
    }
}

class ItemCreationTests: XCTestCase {

    func testAppend_1Item_IncreasesCount() {

        let sidebar = FatSidebar()
        XCTAssertEqual(sidebar.itemCount, 0)

        _ = sidebar.appendItem(title: "irrelevant", callback: { _ in })

        XCTAssertEqual(sidebar.itemCount, 1)
    }

    func testAppend_5Items_IncreasesItemCount() {

        let sidebar = FatSidebar()
        XCTAssertEqual(sidebar.itemCount, 0)

        5.times {
            _ = sidebar.appendItem(title: "irrelevant", callback: { _ in })
        }

        XCTAssertEqual(sidebar.itemCount, 5)
    }

    func testAppend_3Items_InsertsItemsInOrder() {

        let sidebar = FatSidebar()

        _ = sidebar.appendItem(title: "first", callback: { _ in })
        _ = sidebar.appendItem(title: "second", callback: { _ in })
        _ = sidebar.appendItem(title: "third", callback: { _ in })

        XCTAssertEqual(sidebar.item(at: 0)?.title, "first")
        XCTAssertEqual(sidebar.item(at: 1)?.title, "second")
        XCTAssertEqual(sidebar.item(at: 2)?.title, "third")
    }
}
