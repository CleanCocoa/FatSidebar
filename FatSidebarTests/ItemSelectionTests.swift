//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import FatSidebar

class ItemSelectionTests: XCTestCase {

    func testSelectItem_EmptySidebar_DoesNotSelectItem() {

        let sidebar = FatSidebar()
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)

        let result = sidebar.selectItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssertFalse(unknownItem.isSelected)
    }

    func testSelectItem_EmptySidebar_DoesNotChangeSelectedItems() {

        let sidebar = FatSidebar()
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)

        _ = sidebar.selectItem(unknownItem)

        XCTAssertNil(sidebar.selectedItem)
        XCTAssert(sidebar.selectedItems.isEmpty)
    }

    func testSelectItem_SidebarWithDifferentItem_DoesNotSelectItem() {

        let sidebar = FatSidebar()
        sidebar.appendItem(title: "known", callback: irrelevantCallback)
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)

        let result = sidebar.selectItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssertFalse(unknownItem.isSelected)
    }

    func testSelectItem_SidebarWithDifferentItem_DoesNotChangeSelectedItems() {

        let sidebar = FatSidebar()
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)

        _ = sidebar.selectItem(unknownItem)

        XCTAssertNil(sidebar.selectedItem)
        XCTAssert(sidebar.selectedItems.isEmpty)
    }

    func testSelectItem_SidebarWithSelectedItem_SelectsItem() {

        let sidebar = FatSidebar()
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)

        let result = sidebar.selectItem(knownItem)

        XCTAssert(result)
        XCTAssert(knownItem.isSelected)
    }

    func testSelectItem_SidebarWithSelectedItem_SetsSelectedItems() {

        let sidebar = FatSidebar()
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)

        _ = sidebar.selectItem(knownItem)

        XCTAssert(sidebar.selectedItem === knownItem)
        XCTAssertEqual(sidebar.selectedItems.count, 1)
        XCTAssert(sidebar.selectedItems.first === knownItem)
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

    func testSelectItem_SelectingFirstItem_ThenSelectingSecondItem_SetsSelectedItems() {

        let sidebar = FatSidebar()
        let firstItem = sidebar.appendItem(title: "first", callback: irrelevantCallback)
        let secondItem = sidebar.appendItem(title: "second", callback: irrelevantCallback)

        _ = sidebar.selectItem(firstItem)

        XCTAssert(sidebar.selectedItem === firstItem)
        XCTAssertEqual(sidebar.selectedItems.count, 1)
        XCTAssert(sidebar.selectedItems.first === firstItem)

        _ = sidebar.selectItem(secondItem)

        XCTAssert(sidebar.selectedItem === secondItem)
        XCTAssertEqual(sidebar.selectedItems.count, 1)
        XCTAssert(sidebar.selectedItems.first === secondItem)
    }


    // MARK: Querying item selection

    func testSelectedItems_EmptySidebar() {

        let sidebar = FatSidebar()

        XCTAssertNil(sidebar.selectedItem)
        XCTAssert(sidebar.selectedItems.isEmpty)
    }

    func testSelectedItems_SidebarWithUnselectedItems() {

        let sidebar = FatSidebar()
        sidebar.appendItem(title: "first", callback: irrelevantCallback)
        sidebar.appendItem(title: "second", callback: irrelevantCallback)

        XCTAssertNil(sidebar.selectedItem)
        XCTAssert(sidebar.selectedItems.isEmpty)
    }

    func testSelectedItems_SidebarWith_1_of_3_SelectedItems() {

        let sidebar = FatSidebar()
        _ = sidebar.appendItem(title: "1", callback: irrelevantCallback)
        let selectedItem = sidebar.appendItem(title: "2", callback: irrelevantCallback)
        selectedItem.isSelected = true
        _ = sidebar.appendItem(title: "3", callback: irrelevantCallback)

        XCTAssert(sidebar.selectedItem === selectedItem)
        XCTAssertEqual(sidebar.selectedItems.count, 1)
        XCTAssert(sidebar.selectedItems.first === selectedItem)
    }

    func testSelectedItems_SidebarWith_2_of_4_SelectedItems() {

        let sidebar = FatSidebar()
        _ = sidebar.appendItem(title: "1", callback: irrelevantCallback)
        let firstSelectedItem = sidebar.appendItem(title: "2", callback: irrelevantCallback)
        firstSelectedItem.isSelected = true
        let secondSelectedItem = sidebar.appendItem(title: "3", callback: irrelevantCallback)
        secondSelectedItem.isSelected = true
        _ = sidebar.appendItem(title: "3", callback: irrelevantCallback)

        XCTAssert(sidebar.selectedItem === firstSelectedItem)
        XCTAssertEqual(sidebar.selectedItems.count, 2)
        XCTAssert(sidebar.selectedItems[safe: 0] === firstSelectedItem)
        XCTAssert(sidebar.selectedItems[safe: 1] === secondSelectedItem)
    }


    // MARK: - Deselect

    func testDeselectItem_EmptySidebar_DoesNotDeselectItem() {

        let sidebar = FatSidebar()
        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)
        unknownItem.isSelected = true

        let result = sidebar.deselectItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssert(unknownItem.isSelected)
    }

    func testDeselectItem_SidebarWithDifferentItem_DoesNotDeselectItem() {

        let sidebar = FatSidebar()
        _ = sidebar.appendItem(title: "known", callback: irrelevantCallback)

        let unknownItem = FatSidebarItem(title: "unknown", callback: irrelevantCallback)
        unknownItem.isSelected = true

        let result = sidebar.deselectItem(unknownItem)

        XCTAssertFalse(result)
        XCTAssert(unknownItem.isSelected)
    }

    func testDeselectItem_SidebarWithSameItem_ItemIsUnselected_DoesNotDeselectItem() {

        let sidebar = FatSidebar()
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)
        knownItem.isSelected = false

        let result = sidebar.deselectItem(knownItem)

        XCTAssertFalse(result)
        XCTAssertFalse(knownItem.isSelected)
    }

    func testDeselectItem_SidebarWithSameItem_ItemIsSelected_DeselectsItem() {

        let sidebar = FatSidebar()
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)
        knownItem.isSelected = true

        let result = sidebar.deselectItem(knownItem)

        XCTAssert(result)
        XCTAssertFalse(knownItem.isSelected)
    }

    func testDeselectItem_SidebarWithSameItemAndOtherSelectedItem_DeselectsPassedItemOnly() {

        let sidebar = FatSidebar()
        let firstItem = sidebar.appendItem(title: "first", callback: irrelevantCallback)
        firstItem.isSelected = true
        let secondItem = sidebar.appendItem(title: "second", callback: irrelevantCallback)
        secondItem.isSelected = true

        let result = sidebar.deselectItem(firstItem)

        XCTAssert(result)
        XCTAssertFalse(firstItem.isSelected)
        XCTAssert(secondItem.isSelected)
    }

    func testDeselectItem_SelectingItem_ThenDeselecting_ResetsSelectedItems() {

        let sidebar = FatSidebar()
        let knownItem = sidebar.appendItem(title: "known", callback: irrelevantCallback)

        _ = sidebar.selectItem(knownItem)
        _ = sidebar.deselectItem(knownItem)

        XCTAssertNil(sidebar.selectedItem)
        XCTAssert(sidebar.selectedItems.isEmpty)
    }
}
