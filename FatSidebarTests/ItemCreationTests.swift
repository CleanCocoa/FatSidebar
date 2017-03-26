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

extension Array {

    func appending(_ newElement: Element) -> [Element] {
        var result = self
        result.append(newElement)
        return result
    }
}

class ItemCreationTests: XCTestCase {

    func testAppend_1Item_IncreasesCount() {

        let sidebar = FatSidebar()
        XCTAssertEqual(sidebar.itemCount, 0)

        _ = sidebar.appendItem(title: "irrelevant", callback: { _ in })

        XCTAssertEqual(sidebar.itemCount, 1)
    }

    func testAppend_1Item_ReturnsItemWithTitleAndCallback() {

        let sidebar = FatSidebar()
        var didCallCallback = false

        let item = sidebar.appendItem(
            title: "the title!",
            callback: { _ in didCallCallback = true })

        XCTAssertEqual(item.title, "the title!")

        XCTAssertFalse(didCallCallback)
        item.sendAction()
        XCTAssertTrue(didCallCallback)
    }

    func testAppend_5Items_IncreasesItemCount() {

        let sidebar = FatSidebar()
        XCTAssertEqual(sidebar.itemCount, 0)

        5.times {
            _ = sidebar.appendItem(title: "irrelevant", callback: { _ in })
        }

        XCTAssertEqual(sidebar.itemCount, 5)
    }

    func testAppend_5Items_ReturnsItemsWithTitleAndCallback() {

        let sidebar = FatSidebar()
        var calledItems = [FatSidebarItem]()

        let items: [FatSidebarItem] = (0..<5).reduce([]) { (memo, i) in
            let item = sidebar.appendItem(
                title: "\(i)",
                callback: { calledItems.append($0) })
            return memo.appending(item)
        }

        XCTAssertEqual(items.count, 5)
        XCTAssertEqual(
            items.map { $0.title },
            (0..<5).map { "\($0)" })

        XCTAssertTrue(calledItems.isEmpty)
        items.forEach { $0.sendAction() }
        XCTAssertEqual(calledItems.count, 5)
        for (called, original) in zip(calledItems, items) {
            XCTAssertEqual(called.title, original.title)
        }
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
