//
//  EnhancedParentViewController.swift
//  Example
//
//  Created by Panagiotis Sartzetakis on 28/05/2016.
//  Copyright © 2016 Panagiotis Sartzetakis. All rights reserved.
//

import UIKit
import PageViewControllerKit
class EnhancedParentViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    var pageViewController:UIPageViewController!
    var numberOfPages = 5;
    
    
    typealias pageFactory = PageViewControllerFactory<EnhancedChildViewController>
    var datasource : PageViewControllerDatasource<pageFactory,EnhancedChildViewController>?
    
    //EXTRA functionality
    var scrollViewDelegate:PageViewControllerScrollViewDelegate<pageFactory,EnhancedChildViewController>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = numberOfPages;
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.view.frame =  containerView.bounds
        addChildViewController(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        let factory = PageViewControllerFactory { [unowned self] (index) -> EnhancedChildViewController? in
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("EnhancedChildViewController") as! EnhancedChildViewController
            viewController.selectedIndex = index
            viewController.labelName = "label \(index)"
            return viewController
        }
        datasource = PageViewControllerDatasource(pageViewController: pageViewController, pageViewControllerFactory:factory, totalPages: numberOfPages)
        datasource?.selectedIndexCallBack = {[unowned self] index in
            self.updateUIForIndex(index)
        }
        //EXTRA functionality
        scrollViewDelegate = PageViewControllerScrollViewDelegate(pageViewControllerDatasource:datasource!)

        
    }
    
    func updateUIForIndex(index:Int){
        pageControl.currentPage = index
        
    }

}
