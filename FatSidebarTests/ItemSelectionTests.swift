//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import FatSidebar

class ItemSelectionTests: XCTestCase {

    func testSelectItem_EmptySidebar_DoesNotSelectItem() {

        let sidebar = FatSidebar()
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)

        let result = sidebar.selectItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssertFalse(unknownItem.isSelected)
    }

    func testSelectItem_SidebarWithDifferentItem_DoesNotSelectItem() {

        let sidebar = FatSidebar()
        sidebar.appendItem(title: "known", callback: irrelevantCallback)
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)

        let result = sidebar.selectItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssertFalse(unknownItem.isSelected)
    }

    func testSelectItem_SidebarWithSelectedItem_SelectsItem() {

        let sidebar = FatSidebar()
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)

        let result = sidebar.selectItem(knownItem)

        XCTAssert(result)
        XCTAssert(knownItem.isSelected)
    }

    func testSelectItem_SidebarWithSelectedItemAndOthers_SelectsItem() {

        let sidebar = FatSidebar()
        _ = sidebar.appendItem(title: "well known", callback: irrelevantCallback)
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)
        _ = sidebar.appendItem(title: "also known", callback: irrelevantCallback)

        let result = sidebar.selectItem(knownItem)

        XCTAssert(result)
        XCTAssert(knownItem.isSelected)
    }

    func testSelectItem_SelectingFirstItem_ThenSelectingSecondItem_DeselectsFirstItem() {

        let sidebar = FatSidebar()
        let firstItem = sidebar.appendItem(title: "first", callback: irrelevantCallback)
        let secondItem = sidebar.appendItem(title: "second", callback: irrelevantCallback)

        XCTAssertFalse(firstItem.isSelected)
        XCTAssertFalse(secondItem.isSelected)

        let firstResult = sidebar.selectItem(firstItem)

        XCTAssert(firstResult)
        XCTAssert(firstItem.isSelected)
        XCTAssertFalse(secondItem.isSelected)

        let secondResult = sidebar.selectItem(secondItem)

        XCTAssert(secondResult)
        XCTAssertFalse(firstItem.isSelected)
        XCTAssert(secondItem.isSelected)
    }
}
