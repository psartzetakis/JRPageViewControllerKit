//
//  ChildViewController.swift
//  Example
//
//  Created by Panagiotis Sartzetakis on 28/05/2016.
//  Copyright © 2016 Panagiotis Sartzetakis. All rights reserved.
//

import UIKit
import PageViewControllerKit
class SimpleChildViewController: UIViewController,ChildPageViewControllerProtocol {
    @IBOutlet weak var label: UILabel!
    
    var selectedIndex:Int = 0
    var selectedIndexCallBack:((Int)->())?
    var labelName:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = labelName
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedIndexCallBack?(selectedIndex)
    }
    override func viewDidAppear(animated: Bool) {
        selectedIndexCallBack?(selectedIndex)

    }

    

}
