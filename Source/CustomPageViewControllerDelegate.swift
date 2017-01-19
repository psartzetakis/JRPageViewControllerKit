//
//  CustomPageViewControllerDelegate.swift
//  JRPageViewControllerKit
//
//  Created by Panagiotis Sartzetakis on 18/01/2017.
//  Copyright © 2017 Panagiotis Sartzetakis. All rights reserved.
//
import UIKit


public typealias PageViewControllerWillTransitionToViewController = (UIPageViewController, [UIViewController]) -> Void
public typealias PageViewControllerDidFinishAnimating = (UIPageViewController, Bool, [UIViewController], Bool) -> Void
public typealias PageViewControllerSupportedInterfaceOrientations = (UIPageViewController) -> UIInterfaceOrientationMask
public typealias PageViewControllerPreferredInterfaceOrientationForPresentation = (UIPageViewController) -> UIInterfaceOrientation
public typealias PageViewControllerSpineLocationForOrientation = (UIPageViewController, UIInterfaceOrientation) -> UIPageViewControllerSpineLocation

public final class CustomPageViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
    
    let pageViewControllerWillTransitionToViewController: PageViewControllerWillTransitionToViewController
    let pageViewControllerDidFinishAnimating: PageViewControllerDidFinishAnimating
    let pageViewControllerSupportedInterfaceOrientations: PageViewControllerSupportedInterfaceOrientations
    let pageViewControllerPreferredInterfaceOrientationForPresentation: PageViewControllerPreferredInterfaceOrientationForPresentation
    let pageViewControllerSpineLocationForOrientation: PageViewControllerSpineLocationForOrientation
    
    init(
        pageViewControllerWillTransitionToViewController: @escaping PageViewControllerWillTransitionToViewController,
        pageViewControllerDidFinishAnimating: @escaping  PageViewControllerDidFinishAnimating,
        pageViewControllerSupportedInterfaceOrientations: @escaping PageViewControllerSupportedInterfaceOrientations,
        pageViewControllerPreferredInterfaceOrientationForPresentation: @escaping PageViewControllerPreferredInterfaceOrientationForPresentation,
        pageViewControllerSpineLocationForOrientation: @escaping PageViewControllerSpineLocationForOrientation) {
        self.pageViewControllerWillTransitionToViewController = pageViewControllerWillTransitionToViewController
        self.pageViewControllerDidFinishAnimating = pageViewControllerDidFinishAnimating
        self.pageViewControllerSupportedInterfaceOrientations = pageViewControllerSupportedInterfaceOrientations
        self.pageViewControllerPreferredInterfaceOrientationForPresentation = pageViewControllerPreferredInterfaceOrientationForPresentation
        self.pageViewControllerSpineLocationForOrientation = pageViewControllerSpineLocationForOrientation
    }
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pageViewControllerWillTransitionToViewController(pageViewController, pendingViewControllers)
    }
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageViewControllerDidFinishAnimating(pageViewController, finished, previousViewControllers, completed)
    }
    
    @objc public func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return pageViewControllerSupportedInterfaceOrientations(pageViewController)
    }
    
    @objc public func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        return pageViewControllerPreferredInterfaceOrientationForPresentation(pageViewController)
    }
    
    @objc public func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        return pageViewControllerSpineLocationForOrientation(pageViewController, orientation)
    }
}
