//
//  Helpers.swift
//  JRPageViewControllerKit
//
//  Created by Panagiotis Sartzetakis on 29/06/2017.
//  Copyright © 2017 Panagiotis Sartzetakis. All rights reserved.
//

import Foundation
import UIKit

public class FakeViewController: UIViewController {
    var index: Int
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        index = 0
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(index: Int) {
        self.init(nibName: nil, bundle: nil)
        self.index = index
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
