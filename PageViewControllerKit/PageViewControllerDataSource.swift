//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

public protocol ChildPageViewControllerProtocol {
    var selectedIndex: Int { get set }
    var selectedIndexCallBack: ((Int) -> ())? { get set }
    
}
public final class PageViewControllerDatasource<PageViewControllerFactory: PageViewControllerProtocol,
    ViewController: ChildPageViewControllerProtocol>
where PageViewControllerFactory.ViewController == ViewController{
    
    public weak var pageViewController: UIPageViewController?
    public let pageViewControllerFactory: PageViewControllerFactory
    public var pageViewControllerDatasource: UIPageViewControllerDataSource { return mCustomPageViewControllerDataSource }
    public let total: Int
    public var childrenArray: [ViewController?]
    public var displayedIndex: Int = 0
    public var selectedIndexCallBack: ((Int) -> ())?
    
    
    lazy fileprivate var mCustomPageViewControllerDataSource: CustomPageViewControllerDataSource = CustomPageViewControllerDataSource(
        viewControllerAfterViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
            if let viewController = viewController as? ViewController {
                var index = viewController.selectedIndex
                index += 1
                if index == self.total {
                    return nil
                }
                var nextViewController = self.pageViewControllerFactory.viewControllerForIndex(index)
                nextViewController?.selectedIndexCallBack = { [unowned self] index in
                    self.displayedIndex = index
                    self.selectedIndexCallBack?(index)
                }
                self.childrenArray[index] = nextViewController
                return  nextViewController
            }
            return nil
        },
        viewControllerBeforeViewController: { [unowned self] (pageViewController, viewController) -> UIViewController? in
            if let viewController = viewController as? ViewController {
                var index = viewController.selectedIndex
                if index == 0{
                    return nil
                }
                index -= 1
                var previousViewController = self.pageViewControllerFactory.viewControllerForIndex(index)
                previousViewController?.selectedIndexCallBack = { [unowned self] index in
                    self.displayedIndex = index
                    self.selectedIndexCallBack?(index)
                }
                
                self.childrenArray[index] = previousViewController
                
                return  previousViewController
                
                
            }
            return nil
            
        }
    )
    
    public init(pageViewController: UIPageViewController, pageViewControllerFactory: PageViewControllerFactory, totalPages: Int) {
        self.pageViewController = pageViewController
        self.pageViewControllerFactory = pageViewControllerFactory
        let initialVC = self.pageViewControllerFactory.viewControllerForIndex(0)
        self.pageViewController!.setViewControllers([initialVC!], direction: .forward, animated: true, completion: nil)
        childrenArray = [ViewController?](repeating: nil, count: totalPages)
        self.childrenArray[0] = initialVC
        self.total = totalPages
        self.pageViewController?.dataSource = pageViewControllerDatasource
    }
}

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
