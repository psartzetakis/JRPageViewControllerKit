//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

public final class PageViewControllerManager: NSObject, UIScrollViewDelegate  {
    
    //MARK: - UIPageViewControllerDelegate Closures
    var pageViewControllerWillTransitionToViewController: PageViewControllerWillTransitionToViewController?
    var pageViewControllerDidFinishAnimating: PageViewControllerDidFinishAnimating?
    var pageViewControllerSupportedInterfaceOrientations:PageViewControllerSupportedInterfaceOrientations?
    var pageViewControllerPreferredInterfaceOrientationForPresentation: PageViewControllerPreferredInterfaceOrientationForPresentation?
    var pageViewControllerSpineLocationForOrientation: PageViewControllerSpineLocationForOrientation?

    
    public enum ScrollDirection: String {
        case left, right
    }
    
    public typealias NextViewControllerAppears = (ScrollDirection, CGFloat, Int, Int) -> Void
    
    public weak var pageViewController: UIPageViewController?
    public let pageViewControllerFactory: PageViewControllerFactory
    private var customPageViewControllerDataSource: CustomPageViewControllerDataSource?
    private var customPageViewControllerDelegate: CustomPageViewControllerDelegate?
    public let total: Int
    public var children: [UIViewController?]
    public var displayedIndex: Int = 0
    public var didScrollToIndex: ((Int) -> ())?
    public var nextViewControllerAppears: NextViewControllerAppears?
    var destinationVC: UIViewController!
    
    private var scrollView: UIScrollView? {
        return pageViewController?.view.subviews.first as? UIScrollView
    }
    
    public init(pageViewController: UIPageViewController, pageViewControllerFactory: PageViewControllerFactory, totalPages: Int, initialIndex: Int = 0) {
        self.displayedIndex = initialIndex
        self.previousIndex = initialIndex
        self.pageViewController = pageViewController
        self.pageViewControllerFactory = pageViewControllerFactory
        let initialVC = self.pageViewControllerFactory.viewControllerForIndex(initialIndex)
        self.pageViewController!.setViewControllers([initialVC!], direction: .forward, animated: true, completion: nil)
        self.children = [UIViewController?](repeating: nil, count: totalPages)
        self.children[initialIndex] = initialVC
        self.total = totalPages
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

    private func customDelegate() -> CustomPageViewControllerDelegate {
        
        let customPageViewControllerDelegate = CustomPageViewControllerDelegate(
            pageViewControllerWillTransitionToViewController: { [unowned self]  pageViewController, pendingViewControllers in
                guard let pendingVC = pendingViewControllers.first else { return }
                self.destinationVC = pendingVC
                self.pageViewControllerWillTransitionToViewController?(pageViewController, pendingViewControllers)
            },
            pageViewControllerDidFinishAnimating: { [unowned self] pageViewController, finished, previousViewControllers, completed in
                let destinationVC = completed ? self.destinationVC : previousViewControllers.first
                guard let idx = self.children.index(where: { $0 == destinationVC }) else { return }
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
    
    private func customDataSource() -> CustomPageViewControllerDataSource {
        
        let customPageViewControllerDataSource = CustomPageViewControllerDataSource(
            viewControllerAfterViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
                return self.findViewController(pageViewController: pageViewController, viewController: viewController, nextIndex: { $0 + 1 }, predicate: { $0 == self.total })
            },
            viewControllerBeforeViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
                return self.findViewController(pageViewController: pageViewController, viewController: viewController, nextIndex: { $0 - 1 }, predicate: { $0 <= -1 })
            }
        )
        return customPageViewControllerDataSource
    }
    
    public func show(index: Int, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let navigationDirection: UIPageViewControllerNavigationDirection = index > displayedIndex ? .forward : .reverse
        var destinationViewController = children[index]
        if destinationViewController == nil {
            destinationViewController = pageViewControllerFactory.viewControllerForIndex(index)
            children[index] = destinationViewController
        }
        displayedIndex = index
        destinationVC = destinationViewController
        pageViewController?.setViewControllers([destinationViewController!], direction: navigationDirection, animated: animated, completion: completion)
    }

    
    private func findViewController(pageViewController: UIPageViewController, viewController: UIViewController, nextIndex: ((Int) -> Int), predicate: ((Int) -> Bool)) -> UIViewController? {
        
        guard let idx = self.children.index(where: { $0 == viewController }) else {
            return nil
        }
        
        let newIndex = nextIndex(idx)
        if predicate(newIndex) {
            return nil
        }
        
        if let nextViewController = self.children[newIndex] {
            return nextViewController
        }
        
        let nextViewController = self.pageViewControllerFactory.viewControllerForIndex(newIndex)
        self.children[newIndex] = nextViewController
        return nextViewController
    }
    
    
    var maxValue: CGFloat = 0
    let maxTolerance: CGFloat = 0.8
    let minTolerance: CGFloat = 0.2
    var previousIndex: Int = 0
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let width = pageViewController?.view.superview?.frame.size.width else { return }
        guard let destinationIndex = children.index(where: { $0 == destinationVC }) else { return }
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

