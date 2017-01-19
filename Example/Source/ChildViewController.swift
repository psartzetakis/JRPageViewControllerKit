//
//  ChildViewController.swift
//  Example
//
//  Created by Panagiotis Sartzetakis on 18/01/2017.
//  Copyright © 2017 Panagiotis Sartzetakis. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    let colours: [UIColor] = [.red, .blue, .green, .yellow, .purple, .orange]

    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Page \(index)"
        view.backgroundColor = colours[index]
    }

}
