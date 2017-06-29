//
//  CustomPageViewControllerDataSource.swift
//  JRPageViewControllerKit
//
//  Created by Panagiotis Sartzetakis on 18/01/2017.
//  Copyright © 2017 Panagiotis Sartzetakis. All rights reserved.
//
import UIKit


/// A custom implementation of the `UIPageViewControllerDataSource`.
public final class CustomPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    typealias ViewControllerAfterOrBefore = (UIPageViewController, UIViewController) -> UIViewController?
    
    /// A closure that returns the `UIViewController` after the given `UIViewController`.
    let viewControllerAfterViewController: ViewControllerAfterOrBefore
    
    /// A closure that returns the `UIViewController` before the given `UIViewController`.
    let viewControllerBeforeViewController: ViewControllerAfterOrBefore
    
    /// Initialises a `UIPageViewControllerDataSource` instance.
    ///
    /// - Parameters:
    ///   - viewControllerAfterViewController: A closure that will return the `UIViewController` after the given `UIViewController`.
    ///   - viewControllerBeforeViewController: A closure that will return the `UIViewController` before the given `UIViewController`.
    init(viewControllerAfterViewController: @escaping ViewControllerAfterOrBefore, viewControllerBeforeViewController: @escaping ViewControllerAfterOrBefore) {
        self.viewControllerAfterViewController = viewControllerAfterViewController
        self.viewControllerBeforeViewController = viewControllerBeforeViewController
    }

    /// nodoc
    @objc public func  pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllerAfterViewController(pageViewController,viewController)
    }
    
    /// nodoc
    @objc public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllerBeforeViewController(pageViewController, viewController)
    }
}
