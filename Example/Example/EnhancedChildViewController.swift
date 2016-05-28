//
//  EnhancedChildViewController.swift
//  Example
//
//  Created by Panagiotis Sartzetakis on 28/05/2016.
//  Copyright © 2016 Panagiotis Sartzetakis. All rights reserved.
//

import UIKit
import PageViewControllerKit

class EnhancedChildViewController: UIViewController,ScrollPercentageProtocol {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var visibleLabel: UILabel!
    @IBOutlet weak var hiddenLabel: UILabel!
    
    var selectedIndex:Int = 0
    var selectedIndexCallBack:((Int)->())?
    var labelName:String?


    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = labelName
    }

    override func viewWillAppear(animated: Bool) {
        selectedIndexCallBack?(selectedIndex)
    }
    override func viewDidAppear(animated: Bool) {
        selectedIndexCallBack?(selectedIndex)
        
    }
    
    func isBeingPresentedFromDirection(direction:ScrollDirection,withVisiblePercentage percentage:CGFloat){
        visibleLabel.text = "visible \(percentage) from \(direction.description)"
        
    }
    func isBeingDismissedFromDirection(direction:ScrollDirection,withHiddenPercentage percentage:CGFloat){
        hiddenLabel.text = "hidden \(1 - percentage) from \(direction.description)"

    }

    


}
