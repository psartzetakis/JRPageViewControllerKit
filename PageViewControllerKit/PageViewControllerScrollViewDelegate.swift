//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
public enum ScrollDirection:Int{
    case Right = 0, Left = 1
    public var description:String{
        switch self{
        case .Right: return "Right"
        case .Left: return "Left"
        }
    }
}
public protocol ScrollPercentageProtocol:ChildPageViewControllerProtocol{
    func isBeingPresentedFromDirection(direction:ScrollDirection,withVisiblePercentage percentage:CGFloat)
    func isBeingDismissedFromDirection(direction:ScrollDirection,withHiddenPercentage percentage:CGFloat)

}
public final class PageViewControllerScrollViewDelegate <PageViewFactory:PageViewControllerProtocol,ViewController:ScrollPercentageProtocol where PageViewFactory.ViewController == ViewController>: NSObject {

    public weak var scrollView:UIScrollView?
    public var scrollViewDelegate:UIScrollViewDelegate{return mCustomScrollViewDelegate}
    private var numberOfChildren:Int
    private var scrollWidth:CGFloat{
        return scrollView?.bounds.width ?? 0
    }
    
    private var pageViewControllerDatasource:PageViewControllerDatasource<PageViewFactory,ViewController>
    private var lastContentOffset:CGFloat = 0
    private var dismissingIndex:Int = 0
    private var presentingIndex:Int = 0
    private var indexScrollViewDidDecelerate = 0
    
    lazy private var mCustomScrollViewDelegate:CustomScrollViewDelegate = CustomScrollViewDelegate (
        scrollViewDidScroll:{ [unowned self] scrollView in
        
        let activeIndex = self.pageViewControllerDatasource.displayedIndex
        let factor = self.scrollWidth
        let offset =  scrollView.contentOffset.x % factor
        var percentage:CGFloat = offset/factor
        let childrenArray = self.pageViewControllerDatasource.childrenArray
       
        //figure if the scroll is from left to right or vice versa
        if self.lastContentOffset < scrollView.contentOffset.x{
            print("right to left")

            //check if we are on the last page we continue scrolling towards nothing...
            if self.indexScrollViewDidDecelerate != self.numberOfChildren - 1{
                self.presentingIndex = activeIndex
                self.dismissingIndex = activeIndex - 1 >= 0 ? activeIndex - 1 : 0
                
                //if we are going to present something that it has currently shown then there is no need for informing anyone
                if self.presentingIndex != self.indexScrollViewDidDecelerate{
                    if self.dismissingIndex != self.presentingIndex{
                        childrenArray[self.dismissingIndex]?.isBeingDismissedFromDirection(.Left, withHiddenPercentage: 1-percentage)
                    }
                    if percentage != 0 {
                        childrenArray[self.presentingIndex]?.isBeingPresentedFromDirection(.Right, withVisiblePercentage: percentage)
                    }
                }

            }

        }else{
            //left to right
            print("left to right")
            //check if we are in the paging and we are scrolling on the left where nothing exists
            if self.indexScrollViewDidDecelerate != 0{
                self.dismissingIndex = activeIndex + 1 < self.numberOfChildren - 1 ? activeIndex + 1 : self.numberOfChildren - 1
                self.presentingIndex = activeIndex
                percentage = 1-percentage
                
                 //if we are going to present something that it has currently shown then there is no need for informing anyone
                if self.presentingIndex != self.indexScrollViewDidDecelerate{
                    if self.dismissingIndex != self.presentingIndex{
                        childrenArray[self.dismissingIndex]?.isBeingDismissedFromDirection(.Right, withHiddenPercentage: 1-percentage)
                    }
                    if percentage != 0{
                        childrenArray[self.presentingIndex]?.isBeingPresentedFromDirection(.Left, withVisiblePercentage: percentage)
                    }

                }

            }
        }
        self.lastContentOffset = scrollView.contentOffset.x
        
        },scrollViewDidEndDecelerating:{[unowned self] scrollView in
            let childrenArray = self.pageViewControllerDatasource.childrenArray

            self.indexScrollViewDidDecelerate = self.pageViewControllerDatasource.displayedIndex
            childrenArray[self.indexScrollViewDidDecelerate]?.isBeingPresentedFromDirection(.Right, withVisiblePercentage: 1.0)
        })

    
    public init(pageViewControllerDatasource:PageViewControllerDatasource<PageViewFactory,ViewController>) {
        if let pageViewController = pageViewControllerDatasource.pageViewController{
            for view in pageViewController.view.subviews{
                if let scrollView = view as? UIScrollView{
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


public final class CustomScrollViewDelegate:NSObject,UIScrollViewDelegate{
    
    typealias ScrollViewDidScroll = (UIScrollView)->()
    let scrollViewDidScroll:ScrollViewDidScroll
    let scrollViewDidEndDecelerating:ScrollViewDidScroll
    
    init(scrollViewDidScroll:ScrollViewDidScroll,scrollViewDidEndDecelerating:ScrollViewDidScroll){
        self.scrollViewDidScroll = scrollViewDidScroll
        self.scrollViewDidEndDecelerating = scrollViewDidEndDecelerating
    }
    
    @objc public func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
    @objc public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
}