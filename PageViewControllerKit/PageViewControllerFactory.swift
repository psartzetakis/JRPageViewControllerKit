//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

public protocol PageViewControllerProtocol{
    
    associatedtype ViewController: UIViewController
    func viewControllerForIndex(_ index: Int) -> ViewController?
}

public struct PageViewControllerFactory <ViewController:UIViewController>: PageViewControllerProtocol{
    
    public typealias ConfigurationHandler = (Int) -> ViewController?
    fileprivate let configurationHandler: ConfigurationHandler
    
    public init (configuration: @escaping ConfigurationHandler){
        configurationHandler = configuration
    }
    
    public func viewControllerForIndex(_ index: Int) -> ViewController? {
        return configurationHandler(index)
    }
    
}
