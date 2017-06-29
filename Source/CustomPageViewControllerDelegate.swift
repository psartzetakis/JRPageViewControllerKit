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

/// A custom implementation of the `CustomPageViewControllerDelegate`.
public final class CustomPageViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
    /// Called before a gesture-driven transition begins. If the user aborts the navigation gesture, the transition doesn’t complete and the view controllers stay the same.
    let pageViewControllerWillTransitionToViewController: PageViewControllerWillTransitionToViewController
    
    /// Called after a gesture-driven transition completes. 
    ///
    /// Use the completed parameter to distinguish between a transition that completed (the page was turned) and a transition that the user aborted (the page was not turned). 
    ///
    /// The value of the previousViewControllers parameter is the same as what the `viewControllers` method would have returned prior to the page turn.
    let pageViewControllerDidFinishAnimating: PageViewControllerDidFinishAnimating
    
    /// Returns the complete set of supported interface orientations for the page view controller, as determined by the delegate.
    let pageViewControllerSupportedInterfaceOrientations: PageViewControllerSupportedInterfaceOrientations
    
    /// Returns the complete set of supported interface orientations for the page view controller, as determined by the delegate.
    let pageViewControllerPreferredInterfaceOrientationForPresentation: PageViewControllerPreferredInterfaceOrientationForPresentation
    
    /// Returns the spine location for the given orientation.
    ///
    /// Use this method to change the spine location when the device orientation changes, as well as setting new view controllers and changing the double-sided state.
    ///
    /// This method is called only if the transition style is pageCurl.
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
