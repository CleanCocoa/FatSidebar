//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import FatSidebar

func sidebarWithItems(_ count: Int) -> FatSidebar {

    let sidebar = FatSidebar()

    for i in (0..<count) {
        sidebar.appendItem(title: "\(i)", callback: { _ in })
    }

    return sidebar
}

class ItemRemovalTests: XCTestCase {

    // MARK: Remove Single Item

    func testRemove_UnknownItem_DoesNotChangeItemCount() {

        let sidebar = sidebarWithItems(5)
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)
        XCTAssertEqual(sidebar.itemCount, 5)

        let result = sidebar.removeItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssertEqual(sidebar.itemCount, 5)
    }

    func testRemove_KnownItem_ChangesItemCount() {

        let sidebar = sidebarWithItems(4)
        let item = sidebar.appendItem(title: "unknown", callback: irrelevantCallback)
        XCTAssertEqual(sidebar.itemCount, 5)
        XCTAssert(sidebar.contains(item))

        let result = sidebar.removeItem(item)

        XCTAssert(result)
        XCTAssertEqual(sidebar.itemCount, 4)
        XCTAssertFalse(sidebar.contains(item))
    }

    // MARK: Remove All

    func testRemoveAll_EmptySidebar_KeepsCountAt0() {

        let sidebar = FatSidebar()
        XCTAssertEqual(sidebar.itemCount, 0)

        _ = sidebar.removeAllItems()

        XCTAssertEqual(sidebar.itemCount, 0)
    }

    func testRemoveAll_SidebarWith5Items_SetsCountTo0() {

        let sidebar = sidebarWithItems(5)
        XCTAssertEqual(sidebar.itemCount, 5)

        _ = sidebar.removeAllItems()

        XCTAssertEqual(sidebar.itemCount, 0)
    }

    func testRemoveAll_SidebarWith10Items_ReturnsRemovedItemsInOrder() {

        let sidebar = FatSidebar()
        let count = 10

        let sidebarItems: [FatSidebarItem] = (0..<count).reduce([]) { (memo, i) in
            let item = sidebar.appendItem(title: "\(i)", callback: { _ in })

            return memo.appending(item)
        }

        XCTAssertEqual(sidebar.itemCount, count)
        XCTAssertEqual(sidebarItems.count, count)

        let removedItems = sidebar.removeAllItems()

        XCTAssertEqual(removedItems.count, count)
        for (removed, original) in zip(removedItems, sidebarItems) {
            XCTAssertEqual(removed.title, original.title)
        }
    }
}
