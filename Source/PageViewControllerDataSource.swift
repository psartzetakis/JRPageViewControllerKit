//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

public enum ScrollDirection: String {
    case left, right
}

public final class PageViewControllerManager<T: UIViewController>: NSObject, UIScrollViewDelegate  {
    
    //MARK: - UIPageViewControllerDelegate Closures
    var pageViewControllerWillTransitionToViewController: PageViewControllerWillTransitionToViewController?
    var pageViewControllerDidFinishAnimating: PageViewControllerDidFinishAnimating?
    var pageViewControllerSupportedInterfaceOrientations:PageViewControllerSupportedInterfaceOrientations?
    var pageViewControllerPreferredInterfaceOrientationForPresentation: PageViewControllerPreferredInterfaceOrientationForPresentation?
    var pageViewControllerSpineLocationForOrientation: PageViewControllerSpineLocationForOrientation?

    //MARK : - Typealias
    public typealias NextViewControllerAppears = (ScrollDirection, CGFloat, Int, Int) -> Void
    internal typealias ViewControllerForIndex = ((Int) -> T?)
    
    public var nextViewControllerAppears: NextViewControllerAppears?
    private let viewControllerForIndex:ViewControllerForIndex!

    public var didScrollToIndex: ((Int) -> ())?

    public weak var pageViewController: UIPageViewController?
    private var customPageViewControllerDataSource: CustomPageViewControllerDataSource?
    private var customPageViewControllerDelegate: CustomPageViewControllerDelegate?
    public let totalPages: Int
    public var viewControllers: [T?]
    public var displayedIndex: Int = 0
    public var displayedViewController: T? {
        return viewControllers[displayedIndex]
    }
    
    var destinationVC: T!
    
    private var scrollView: UIScrollView? {
        return pageViewController?.view.subviews.first as? UIScrollView
    }
    
    private subscript(index: Int) -> T? {
        get {
            if let viewController = viewControllers[index] {
                return viewController
            }
            let viewController = viewControllerForIndex(index)
            viewControllers[index] = viewController
            
            return viewController
        }
    }
    
    public init(pageViewController: UIPageViewController, viewControllerForIndex: @escaping ((Int) -> T?), totalPages: Int, initialIndex: Int = 0) {
        self.displayedIndex = initialIndex
        self.previousIndex = initialIndex
        self.pageViewController = pageViewController
        self.viewControllers = [T?](repeating: nil, count: totalPages)
        self.viewControllerForIndex = viewControllerForIndex
        let initialVC = viewControllerForIndex(initialIndex)
        self.pageViewController!.setViewControllers([initialVC!], direction: .forward, animated: true, completion: nil)
        self.viewControllers[initialIndex] = initialVC
        self.totalPages = totalPages
        super.init()
    }

    
    public var pageViewControllerDataSource: CustomPageViewControllerDataSource {
        if customPageViewControllerDataSource == nil {
            customPageViewControllerDataSource = customDataSource()
        }
        return customPageViewControllerDataSource!
    }
    
    public var pageViewControllerDelegate: CustomPageViewControllerDelegate {
        if customPageViewControllerDelegate == nil {
            customPageViewControllerDelegate = customDelegate()
        }
        scrollView?.delegate = self
        return customPageViewControllerDelegate!
    }
    
    public func show(index: Int, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let navigationDirection: UIPageViewControllerNavigationDirection = index > displayedIndex ? .forward : .reverse
        guard let destinationViewController = self[index] else { return }
        displayedIndex = index
        destinationVC = destinationViewController
        pageViewController?.setViewControllers([destinationViewController], direction: navigationDirection, animated: animated, completion: completion)
    }

    
    fileprivate func findViewController(pageViewController: UIPageViewController, viewController: UIViewController, nextIndex: ((Int) -> Int), predicate: ((Int) -> Bool)) -> UIViewController? {
        
        guard let idx = self.viewControllers.index(where: { $0 == viewController }) else { return nil }
        
        let newIndex = nextIndex(idx)
        if predicate(newIndex) {
            return nil
        }
        
        let nextViewController = self[newIndex]
        return nextViewController
    }
    
    
    var maxValue: CGFloat = 0
    let maxTolerance: CGFloat = 0.8
    let minTolerance: CGFloat = 0.2
    var previousIndex: Int = 0
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let width = pageViewController?.view.superview?.frame.size.width else { return }
        guard let destinationIndex = viewControllers.index(where: { $0 == destinationVC }) else { return }
        let offset = max(0, scrollView.contentOffset.x)
        
        let ratio = offset / width
        var direction: ScrollDirection!
        var visibleRatio: CGFloat = 0
        if offset > width {
            direction = .right
            visibleRatio = ratio.truncatingRemainder(dividingBy: 1)
        } else {
            direction = .left
            visibleRatio = 1 - ratio
        }
        
        if visibleRatio < minTolerance &&  maxValue > maxTolerance && previousIndex == destinationIndex {
            visibleRatio = 1
            maxValue = 0
        }
        
        previousIndex = destinationIndex
        maxValue = min(1, visibleRatio)
        nextViewControllerAppears?(direction, maxValue, previousIndex, destinationIndex)
    }
}

//MARK: - Custom datasource / delegate
fileprivate extension PageViewControllerManager {
    
    
    fileprivate func customDelegate() -> CustomPageViewControllerDelegate {
        
        let customPageViewControllerDelegate = CustomPageViewControllerDelegate(
            
            pageViewControllerWillTransitionToViewController: { [unowned self]  pageViewController, pendingViewControllers in
                guard let pendingVC = pendingViewControllers.first as? T else { return }
                self.destinationVC = pendingVC
                self.pageViewControllerWillTransitionToViewController?(pageViewController, pendingViewControllers)
            },
            pageViewControllerDidFinishAnimating: { [unowned self] pageViewController, finished, previousViewControllers, completed in
                let destinationVC = completed ? self.destinationVC : previousViewControllers.first
                guard let idx = self.viewControllers.index(where: { $0 == destinationVC }) else { return }
                self.displayedIndex = idx
                self.didScrollToIndex?(idx)
                self.pageViewControllerDidFinishAnimating?(pageViewController, finished, previousViewControllers, completed)
            },
            pageViewControllerSupportedInterfaceOrientations: { [unowned self] pageViewController in
                if let pageViewControllerSupportedInterfaceOrientations = self.pageViewControllerSupportedInterfaceOrientations {
                    return pageViewControllerSupportedInterfaceOrientations(pageViewController)
                }
                return .all
            },
            pageViewControllerPreferredInterfaceOrientationForPresentation: { [unowned self] pageViewController in
                if let pageViewControllerPreferredInterfaceOrientationForPresentation = self.pageViewControllerPreferredInterfaceOrientationForPresentation {
                    return pageViewControllerPreferredInterfaceOrientationForPresentation(pageViewController)
                }
                return .unknown
            },
            pageViewControllerSpineLocationForOrientation: { [unowned self] pageViewController, interfaceOrientation in
                if let pageViewControllerSpineLocationForOrientation = self.pageViewControllerSpineLocationForOrientation {
                    return pageViewControllerSpineLocationForOrientation(pageViewController, interfaceOrientation)
                }
                if pageViewController.transitionStyle == .scroll {
                    return .none
                }
                return .min
        })
        
        return customPageViewControllerDelegate
    }
    
    fileprivate func customDataSource() -> CustomPageViewControllerDataSource {
        
        let customPageViewControllerDataSource = CustomPageViewControllerDataSource(
            viewControllerAfterViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
                return self.findViewController(pageViewController: pageViewController, viewController: viewController, nextIndex: { $0 + 1 }, predicate: { $0 == self.totalPages })
            },
            viewControllerBeforeViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
                return self.findViewController(pageViewController: pageViewController, viewController: viewController, nextIndex: { $0 - 1 }, predicate: { $0 <= -1 })
            }
        )
        return customPageViewControllerDataSource
    }

}

