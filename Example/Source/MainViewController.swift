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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Create a factory that will return a viewController for a specific index.
        let factory: ((Int) -> ChildViewController?) = { [unowned self] index -> ChildViewController? in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
            viewController.index = index
            return viewController
        }
        
        // 2. Instantiate a PageViewControllerManager.
        pageViewControllerManager = PageViewControllerManager(insertIn: containerView, inViewController: self, totalPages: 6, viewControllerForIndex: factory)
        
        // 3. Get notified when user swipped to another viewController.
        pageViewControllerManager.didScrollToIndex = { index in
            // The index that the user has just scrolled.
        }
        
        // 4. Get notified when another viewController is about to be appeared.
        pageViewControllerManager.nextViewControllerAppears = { [unowned self] direction, ratio, destinationIndex in
            let ratio = String(format: "%.2f", ratio)
            let text = "direction:\(direction.rawValue), ratio:\(ratio),\n  to \(destinationIndex)"
            self.header.text = text
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        pageViewControllerManager.show(viewControllerAt: sender.tag, animated: true)
    }
}
