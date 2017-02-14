//
//  ExampleViewController.swift
//  Example
//
//  Created by Panagiotis Sartzetakis on 18/01/2017.
//  Copyright © 2017 Panagiotis Sartzetakis. All rights reserved.
//

import UIKit
import JRPageViewControllerKit

class MainViewController: UIViewController {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var pageViewControllerManager: PageViewControllerManager<ChildViewController>!
    var pageViewController: UIPageViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController(with: 0)
        // Do any additional setup after loading the view.
    }

    private func setupPageViewController(with initialIndex: Int) {
        
        //attach the pageViewController
        let options = [UIPageViewControllerOptionInterPageSpacingKey: 0]
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        pageViewController.view.frame =  containerView.bounds
        addChildViewController(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        
        let factory: ((Int) -> ChildViewController?) = { [unowned self] index -> ChildViewController? in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
            viewController.index = index
            return viewController
        }
        
        pageViewControllerManager = PageViewControllerManager(pageViewController: pageViewController, viewControllerForIndex: factory, totalPages: 6, initialIndex: initialIndex)
        pageViewController.dataSource = pageViewControllerManager.pageViewControllerDataSource
        pageViewController.delegate = pageViewControllerManager.pageViewControllerDelegate
        
        pageViewControllerManager.didScrollToIndex = { index in
            print("callback index \(index)")
        }
        
        pageViewControllerManager.nextViewControllerAppears = { [unowned self] direction, visibleRatio, originalIndex, destinationIndex in
            let ratio = String(format: "%.2f", visibleRatio)
            let text = "direction:\(direction.rawValue), ratio:\(ratio),\n from:\(originalIndex) to \(destinationIndex)"
            self.header.text = text
        }

    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        pageViewControllerManager.show(index: sender.tag, animated: true)
    }
}
