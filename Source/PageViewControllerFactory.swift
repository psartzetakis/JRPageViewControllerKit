//
//  License
//  Copyright (c) 2016-present Panagiotis Sartzetakis
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

public struct PageViewControllerFactory {
    
    public typealias ConfigurationHandler = (Int) -> UIViewController?
    fileprivate let configurationHandler: ConfigurationHandler
    
    public init (configuration: @escaping ConfigurationHandler){
        configurationHandler = configuration
    }
    
    public func viewControllerForIndex(_ index: Int) -> UIViewController? {
        return configurationHandler(index)
    }
    
}
