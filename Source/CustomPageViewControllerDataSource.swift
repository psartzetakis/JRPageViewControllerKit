//
//  CustomPageViewControllerDataSource.swift
//  JRPageViewControllerKit
//
//  Created by Panagiotis Sartzetakis on 18/01/2017.
//  Copyright © 2017 Panagiotis Sartzetakis. All rights reserved.
//
import UIKit

public final class CustomPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    typealias ViewControllerAfterOrBefore = (UIPageViewController, UIViewController) -> UIViewController?
    
    let viewControllerAfterViewController: ViewControllerAfterOrBefore
    let viewControllerBeforeViewController: ViewControllerAfterOrBefore
    
    init(viewControllerAfterViewController: @escaping ViewControllerAfterOrBefore,viewControllerBeforeViewController :@escaping ViewControllerAfterOrBefore) {
        self.viewControllerAfterViewController = viewControllerAfterViewController
        self.viewControllerBeforeViewController = viewControllerBeforeViewController
    }
    
    @objc public func  pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllerAfterViewController(pageViewController,viewController)
    }
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllerBeforeViewController(pageViewController,viewController)
    }
}
