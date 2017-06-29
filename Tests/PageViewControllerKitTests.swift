//
//  PageViewControllerKitTests.swift
//  PageViewControllerKitTests
//
//  Created by Panagiotis Sartzetakis on 28/05/2016.
//  Copyright © 2016 Panagiotis Sartzetakis. All rights reserved.
//

import XCTest
@testable import JRPageViewControllerKit

class PageViewControllerKitTests: XCTestCase {
    
    let fakeView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 530))
    let mainViewController = UIViewController(nibName: nil, bundle: nil)
   
    override func setUp() {
        super.setUp()
        
        UIApplication.shared.keyWindow?.rootViewController = mainViewController
        _ = mainViewController.view

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_bothDelegate_andDataSource_areNotNil() {
        
        // GIVEN: A factory.
        let factory: ((Int) -> FakeViewController) = { index in
            return FakeViewController(index: index)
        }
        
        // WHEN: We instantiate a  pageViewControllerManager.
        let pageViewControllerManager = PageViewControllerManager(insertIn: fakeView, inViewController: mainViewController, totalPages: 2, viewControllerForIndex: factory)
        
        // THEN: The delegate and the dataSource are not nil.
        XCTAssertNotNil(pageViewControllerManager.dataSource)
        XCTAssertNotNil(pageViewControllerManager.delegate)

    }

    func test_thatWhenCallingShowWithinRange_theViewControllerThatIsAppeared_isTheCorrectOne() {
        
        // GIVEN: A factory and pageViewControllerManager.
        let factory: ((Int) -> FakeViewController) = { index in
            return FakeViewController(index: index)
        }
        let pageViewControllerManager = PageViewControllerManager(insertIn: fakeView, inViewController: mainViewController, totalPages: 2, viewControllerForIndex: factory)

        // WHEN: We request to show a viewController at a specific index.
        pageViewControllerManager.show(viewControllerAt: 1, animated: false)

        // THEN: The viewController that is displayed is the correct one.
        XCTAssertEqual(pageViewControllerManager.activeIndex, 1)
    }
    
    func test_thatWhenCallingShowOutOfRange_theViewController_doesNotChange() {
        
        // GIVEN: A factory and pageViewControllerManager.
        let factory: ((Int) -> FakeViewController) = { index in
            return FakeViewController(index: index)
        }
        let pageViewControllerManager = PageViewControllerManager(insertIn: fakeView, inViewController: mainViewController, totalPages: 2, viewControllerForIndex: factory)
        
        // WHEN: We request to show a viewController for an index that doesn't exist.
        pageViewControllerManager.show(viewControllerAt: 2, animated: false)
        
        // THEN: The viewController that is displayed remains unchanged.
        XCTAssertEqual(pageViewControllerManager.activeIndex, 0)
    }

}
