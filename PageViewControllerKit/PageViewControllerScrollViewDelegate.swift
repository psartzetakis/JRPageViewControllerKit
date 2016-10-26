//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
public enum ScrollDirection: Int{
    case right = 0, left = 1
    public var description: String{
        switch self{
        case .right: return "Right"
        case .left: return "Left"
        }
    }
}

public protocol ScrollPercentageProtocol: ChildPageViewControllerProtocol{
    func isBeingPresentedFromDirection(_ direction: ScrollDirection, withVisiblePercentage percentage: CGFloat)
    func isBeingDismissedFromDirection(_ direction: ScrollDirection, withHiddenPercentage percentage: CGFloat)

}
public final class PageViewControllerScrollViewDelegate <PageViewFactory: PageViewControllerProtocol,ViewController: ScrollPercentageProtocol>: NSObject where PageViewFactory.ViewController == ViewController {

    public weak var scrollView: UIScrollView?
    public var scrollViewDelegate: UIScrollViewDelegate { return mCustomScrollViewDelegate }
    fileprivate var numberOfChildren: Int
    fileprivate var scrollWidth: CGFloat {
        return scrollView?.bounds.width ?? 0
    }
    
    fileprivate var pageViewControllerDatasource: PageViewControllerDatasource<PageViewFactory,ViewController>
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var dismissingIndex: Int = 0
    fileprivate var presentingIndex: Int = 0
    fileprivate var indexScrollViewDidDecelerate = 0
    
    lazy fileprivate var mCustomScrollViewDelegate: CustomScrollViewDelegate = CustomScrollViewDelegate (
        scrollViewDidScroll:{ [unowned self] scrollView in
        
        let activeIndex = self.pageViewControllerDatasource.displayedIndex
        let factor = self.scrollWidth
        let offset =  scrollView.contentOffset.x.truncatingRemainder(dividingBy: factor)
        var percentage:CGFloat = offset/factor
        let childrenArray = self.pageViewControllerDatasource.childrenArray
       
        //figure if the scroll is from left to right or vice versa
        if self.lastContentOffset < scrollView.contentOffset.x {

            //check if we are on the last page we continue scrolling towards nothing...
            if self.indexScrollViewDidDecelerate != self.numberOfChildren - 1 {
                self.presentingIndex = activeIndex
                self.dismissingIndex = activeIndex - 1 >= 0 ? activeIndex - 1 : 0
                
                //if we are going to present something that it has currently shown then there is no need for informing anyone
                if self.presentingIndex != self.indexScrollViewDidDecelerate {
                    if self.dismissingIndex != self.presentingIndex {
                        childrenArray[self.dismissingIndex]?.isBeingDismissedFromDirection(.left, withHiddenPercentage: 1-percentage)
                    }
                    if percentage != 0 {
                        childrenArray[self.presentingIndex]?.isBeingPresentedFromDirection(.right, withVisiblePercentage: percentage)
                    }
                }

            }

        } else {
            //left to right
            
            //check if we are in the paging and we are scrolling on the left where nothing exists
            if self.indexScrollViewDidDecelerate != 0 {
                self.dismissingIndex = activeIndex + 1 < self.numberOfChildren - 1 ? activeIndex + 1 : self.numberOfChildren - 1
                self.presentingIndex = activeIndex
                percentage = 1-percentage
                
                 //if we are going to present something that it has currently shown then there is no need for informing anyone
                if self.presentingIndex != self.indexScrollViewDidDecelerate {
                    if self.dismissingIndex != self.presentingIndex{
                        childrenArray[self.dismissingIndex]?.isBeingDismissedFromDirection(.right, withHiddenPercentage: 1-percentage)
                    }
                    if percentage != 0 {
                        childrenArray[self.presentingIndex]?.isBeingPresentedFromDirection(.left, withVisiblePercentage: percentage)
                    }

                }

            }
        }
        self.lastContentOffset = scrollView.contentOffset.x
        
        },scrollViewDidEndDecelerating:{ [unowned self] scrollView in
            let childrenArray = self.pageViewControllerDatasource.childrenArray

            self.indexScrollViewDidDecelerate = self.pageViewControllerDatasource.displayedIndex
            childrenArray[self.indexScrollViewDidDecelerate]?.isBeingPresentedFromDirection(.right, withVisiblePercentage: 1.0)
        })

    
    public init(pageViewControllerDatasource: PageViewControllerDatasource<PageViewFactory,ViewController>) {
        if let pageViewController = pageViewControllerDatasource.pageViewController {
            for view in pageViewController.view.subviews {
                if let scrollView = view as? UIScrollView {
                    self.scrollView = scrollView
                }
            }
        }
        
        self.pageViewControllerDatasource = pageViewControllerDatasource
        self.numberOfChildren = pageViewControllerDatasource.total
        super.init()
        self.scrollView?.delegate = scrollViewDelegate


    }
}


public final class CustomScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    typealias ScrollViewDidScroll = (UIScrollView) -> ()
    let scrollViewDidScroll: ScrollViewDidScroll
    let scrollViewDidEndDecelerating: ScrollViewDidScroll
    
    init(scrollViewDidScroll: @escaping ScrollViewDidScroll, scrollViewDidEndDecelerating: @escaping ScrollViewDidScroll) {
        self.scrollViewDidScroll = scrollViewDidScroll
        self.scrollViewDidEndDecelerating = scrollViewDidEndDecelerating
    }
    
    @objc public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
    @objc public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
}
