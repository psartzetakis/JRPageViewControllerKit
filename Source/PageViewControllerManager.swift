//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit


/// Enum the describes the direction which the next `UIViewController` is going to appear.
///
/// - leading: If the next `UIViewController` is going to be appeared from the leading side.
/// - trailing: If the next `UIViewController` is going to be appeared from the trailing side.
public enum ScrollDirection: String {
    case leading, trailing
}


/// A `PageViewControllerManager` manages the `UIPageViewController`. It uses its custom delegate and dataSource.
public final class PageViewControllerManager<T: UIViewController>: NSObject, UIScrollViewDelegate  {
    
    //MARK: - UIPageViewControllerDelegate Closures
    var pageViewControllerWillTransitionToViewController: PageViewControllerWillTransitionToViewController?
    var pageViewControllerDidFinishAnimating: PageViewControllerDidFinishAnimating?
    var pageViewControllerSupportedInterfaceOrientations:PageViewControllerSupportedInterfaceOrientations?
    var pageViewControllerPreferredInterfaceOrientationForPresentation: PageViewControllerPreferredInterfaceOrientationForPresentation?
    var pageViewControllerSpineLocationForOrientation: PageViewControllerSpineLocationForOrientation?

    public typealias ViewControllerForIndex = ((Int) -> T?)
    
    /// A closure that returns a `UIViewController` for the requested index.
    private let viewControllerForIndex: ViewControllerForIndex!
    
    /// The `CustomPageViewControllerDelegate` uses that instance to keep track of the next `UIViewController` that is about to be presented.
    fileprivate var destinationViewController: T!
    
    /// Returns the `UIScrollView` that exists inside the `UIPageViewController`.
    private var scrollView: UIScrollView? {
        return pageViewController?.view.subviews.first as? UIScrollView
    }
    
    /// Returns a `UIViewController` instance for a specific index. If the `UIViewController` is cached it returns the cached on, otherwise it asks for a new one.
    ///
    /// - Parameter index: The index that we are looking the `UIViewController`.
    fileprivate subscript(index: Int) -> T? {
        get {
            if index < 0 || index > childrenViewControllers.count - 1 {
                return nil
            }
            if let viewController = childrenViewControllers[index] {
                return viewController
            }
            let viewController = viewControllerForIndex(index)
            childrenViewControllers[index] = viewController
            
            return viewController
        }
    }
    
    /// The instance of `UIPageViewController` that we instantiated.
    fileprivate var pageViewController: UIPageViewController!
    
    /// The spacing between the `UIViewController`s.
    private var spacing: CGFloat = 0
    
    /// The custom dataSource.
    internal var dataSource: CustomPageViewControllerDataSource!
    
    /// The custom delegate.
    internal var delegate: CustomPageViewControllerDelegate!
    
    /// A closure that provides the index of the new page that the user scrolled.
    public var didScrollToIndex: ((Int) -> ())?
    
    public typealias NextViewControllerAppears = (ScrollDirection, CGFloat, Int) -> Void
    
    /// A closure that provides the percentage on the next `UIViewController` who is about to be presented.
    public var nextViewControllerAppears: NextViewControllerAppears?

    /// Returns the number of pages of the `UIPageViewController`.
    public var totalPages: Int {
        return childrenViewControllers.count
    }
    
    /// Returns an array of all the childViewControllers of the `UIPageViewController`.
    public var childrenViewControllers: [T?]

    /// Returns the index that the `UIPageViewController` is currently displaying.
    public var activeIndex: Int
    
    /// Returns the `UIViewController` that is currently displayed in the `UIPageViewController`.
    public var displayedViewController: T? {
        return childrenViewControllers[activeIndex]
    }
    
    /// Initialises a PageViewControllerManager object. This instance manages by default the `dataSource` of the `UIPageViewController`. It also manages the instance its `delegate`, if you need any delegate information you can access them through the closures that are being provided.
    ///
    /// - Parameters:
    ///   - containerView: The view that we want to add the `UIPageViewController` as subView.
    ///   - boundsRect: The desired rect for the `UIPageViewController`. If it is `zero` then the bounds of the `containerView` will be used instead.
    ///   - space: The space between the children of the `UIPageViewController`. Default is `zero`.
    ///   - inViewController: The parent `UIViewController` which will host the `UIPageViewController`.
    ///   - totalPages: The total number of childen `UIViewController`s.
    ///   - initialIndex: The index that the `UIPageViewController` will display once launched.
    ///   - viewControllerForIndex: A closure which provides an index and requires back a `UIViewController` instance.
    public init(insertIn containerView: UIView,
                boundsRect: CGRect = .zero,
                spacing: CGFloat = 0,
                inViewController: UIViewController,
                totalPages: Int,
                initialIndex: Int = 0,
                viewControllerForIndex: @escaping ViewControllerForIndex) {
        

        childrenViewControllers = [T?](repeating: nil, count: totalPages)
        self.viewControllerForIndex = viewControllerForIndex
        self.activeIndex = initialIndex
        self.spacing = spacing

        let options = [UIPageViewControllerOptionInterPageSpacingKey: spacing]
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        pageViewController.view.frame =  boundsRect == .zero ? containerView.bounds : boundsRect
        inViewController.addChildViewController(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: inViewController)

        super.init()

        scrollView?.delegate = self

        dataSource = customDataSource()
        delegate = customDelegate()

        let initialViewController = self[initialIndex]
        pageViewController.setViewControllers([initialViewController!], direction: .forward, animated: true, completion: nil)
        pageViewController.dataSource = dataSource
        pageViewController.delegate = delegate

    }
    
    /// Presents the `UIViewController` for a specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the `UIViewController` that we want to present.
    ///   - animated: A boolen value that describes if we want the transition to be animated or not.
    ///   - completion: A completion closure that is called once the transitions finishes.
    public func show(viewControllerAt index: Int, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        let navigationDirection: UIPageViewControllerNavigationDirection = index > activeIndex ? .forward : .reverse
        guard let destinationViewController = self[index] else { return }
        activeIndex = index
        self.destinationViewController = destinationViewController
        pageViewController?.setViewControllers([destinationViewController], direction: navigationDirection, animated: animated, completion: completion)
    }
    
    /// One of the delegate methods of `UIScrollViewDelegate` that provides the offset during scroll.
    ///
    /// - Parameter scrollView: The scrollview where the delegate returns.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        guard let destinationIndex = childrenViewControllers.index(where: { $0 == destinationViewController }) else { return }

        let offset = max(0, scrollView.contentOffset.x)

        //when offset == width a swipe has been completed and the offset resets and send ratio = 0, so we discard that case.
        guard offset != width else { return }
        let ratio = offset / width

        var direction: ScrollDirection!
        var visibleRatio: CGFloat = 0
        
        if offset > width {
            direction = .trailing
            
            //when it completes ratio will be 2, because though 2 % 1= 0 we reset it to 1.
            if ratio == 2 {
                visibleRatio = 1
            } else {
                visibleRatio = ratio.truncatingRemainder(dividingBy: 1)
            }
            
        } else {
            direction = .leading
            visibleRatio = 1 - ratio
        }
        
        let maxValue = min(1, visibleRatio)
        nextViewControllerAppears?(direction, maxValue, destinationIndex)
    }
}


//MARK: - Custom delegate
fileprivate extension PageViewControllerManager {
    
    /// A function that returns a `CustomPageViewControllerDelegate` instance.
    ///
    /// - Returns: a `CustomPageViewControllerDelegate` instance.
    fileprivate func customDelegate() -> CustomPageViewControllerDelegate {
        
        let customPageViewControllerDelegate = CustomPageViewControllerDelegate(
            
            pageViewControllerWillTransitionToViewController: { [unowned self]  pageViewController, pendingViewControllers in
                guard let pendingVC = pendingViewControllers.first as? T else { return }
                self.destinationViewController = pendingVC
                self.pageViewControllerWillTransitionToViewController?(pageViewController, pendingViewControllers)
            },
            pageViewControllerDidFinishAnimating: { [unowned self] pageViewController, finished, previousViewControllers, completed in
                let destinationVC = completed ? self.destinationViewController : previousViewControllers.first
                guard let idx = self.childrenViewControllers.index(where: { $0 == destinationVC }) else { return }
                if self.activeIndex != idx {
                    self.activeIndex = idx
                    self.didScrollToIndex?(idx)
                }
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
    

}

//MARK: - Custom datasource

fileprivate extension PageViewControllerManager {
    
    /// Convenience method for searching between the existing `UIViewController`s and returns the next or the previous one if exists.
    ///
    /// - Parameters:
    ///   - pageViewController: The `UIPageViewController` instance that contains the requested `UIViewController`.
    ///   - viewController: The current `UIViewController`.
    ///   - nextIndex: A closure that defines how the next index will be calculated.
    ///   - predicate: A closure that evaluates when there is not an available `UIViewController`.
    /// - Returns: The next or previous `UIViewController`.
    fileprivate func findViewController(pageViewController: UIPageViewController, viewController: UIViewController, nextIndex: ((Int) -> Int), predicate: ((Int) -> Bool)) -> UIViewController? {
        
        guard let idx = self.childrenViewControllers.index(where: { $0 == viewController }) else { return nil }
        
        let newIndex = nextIndex(idx)
        if predicate(newIndex) {
            return nil
        }
        
        let nextViewController = self[newIndex]
        return nextViewController
    }

    
    /// A function that returns a `CustomPageViewControllerDataSource` instance.
    ///
    /// - Returns: a `CustomPageViewControllerDataSource` instance.
    fileprivate func customDataSource() -> CustomPageViewControllerDataSource {
        
        let customPageViewControllerDataSource = CustomPageViewControllerDataSource(
            viewControllerAfterViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
                return self.findViewController(pageViewController: pageViewController,
                                               viewController: viewController,
                                               nextIndex: { $0 + 1 },
                                               predicate: { $0 == self.totalPages })
            },
            viewControllerBeforeViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
                return self.findViewController(pageViewController: pageViewController,
                                               viewController: viewController,
                                               nextIndex: { $0 - 1 },
                                               predicate: { $0 <= -1 })
            }
        )
        return customPageViewControllerDataSource
    }

}
