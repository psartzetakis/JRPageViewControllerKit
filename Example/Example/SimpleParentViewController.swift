//
//  ViewController.swift
//  Example
//
//  Created by Panagiotis Sartzetakis on 28/05/2016.
//  Copyright © 2016 Panagiotis Sartzetakis. All rights reserved.
//

import UIKit
import PageViewControllerKit

class SimpleParentViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    var pageViewController:UIPageViewController!
    var numberOfPages = 5;

    
    typealias pageFactory = PageViewControllerFactory<SimpleChildViewController>
    var datasource : PageViewControllerDatasource<pageFactory,SimpleChildViewController>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = numberOfPages;
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.view.frame =  containerView.bounds
        addChildViewController(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)

        let factory = PageViewControllerFactory { [unowned self] (index) -> SimpleChildViewController? in
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleChildViewController") as! SimpleChildViewController
            viewController.selectedIndex = index
            viewController.labelName = "label \(index)"
            return viewController
        }
        datasource = PageViewControllerDatasource(pageViewController: pageViewController, pageViewControllerFactory:factory, totalPages: numberOfPages)
        datasource?.selectedIndexCallBack = {[unowned self] index in
            self.updateUIForIndex(index)
        }

    }
    
    func updateUIForIndex(index:Int){
        pageControl.currentPage = index
        
    }



}

