# PageViewControllerKit

PageViewControllerKit is just a simple wrapper written is Swift that puts all the boiler plate code associated with the UIPageViewController in the right place. It also provides a feature (Beta) which enables each child
of the UIPageViewController to know how much of its view has been presented (when it is being presented) and how much of its view has been dismissed (when it is being dismissed).
For the time being i don't actively maintain this rep but from time to time i will contribute in order to bring that extra feature to a more stable state.

There is an example available where you can check how it works.

# Installation

At the moment is not available through ```Cocoapods``` or ```Carthage``` :( .
For now all you have to do is:
 1. Drag and Drop the PageViewControllerKit.xcodeproj to your project
 2. Go to your target's settings, hit the "+" under the "Linked Frameworkd and Binaries" section, and select the PageViewControllerKit.framework
 3. ```import PageViewControllerKit```

# Usage

The UIViewController that will be the child of the UIPageViewController has to adopt at least the ```ChildPageViewControllerProtocol ```.
I have noticed the using the native pageControl of UIPageViewController results in a pointing at the wrong dot if the users starts scrollings fast as a result i keep track of the active index that UIPageViewController is currently presenting by updating the ```selectedIndex``` in the ```viewWillAppear``` and ```viewDidAppear``` of the child UIViewController.

```
import PageViewControllerKit
class SimpleChildViewController: UIViewController,ChildPageViewControllerProtocol {

  //Required by ChildPageViewControllerProtocol
    var selectedIndex:Int = 0
    var selectedIndexCallBack:((Int)->())?

    override func viewWillAppear(animated: Bool) {
        selectedIndexCallBack?(selectedIndex)
    }
    override func viewDidAppear(animated: Bool) {
        selectedIndexCallBack?(selectedIndex)
    }

}
```

The UIViewController that will have the UIPageViewController's instance will have to instatiate a ```PageViewControllerDatasource```.

```
    typealias pageFactory = PageViewControllerFactory<SimpleChildViewController>
    var datasource : PageViewControllerDatasource<pageFactory,SimpleChildViewController>?
```

In the ViewDidLoad after you initialize the pageViewController all you have to do is pass an instance of ```PageViewControllerFactory``` to the ```PageViewControllerDatasource```.

```
   override func viewDidLoad() {
        super.viewDidLoad()
        
        let factory = PageViewControllerFactory { [unowned self] (index) -> SimpleChildViewController? in
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("SimpleChildViewController") as! SimpleChildViewController
            viewController.selectedIndex = index
            viewController.labelName = "label \(index)"
            return viewController
        }
        datasource = PageViewControllerDatasource(pageViewController: pageViewController, pageViewControllerFactory:factory, totalPages: 3)
        datasource?.selectedIndexCallBack = {[unowned self] index in
            self.updateUIForIndex(index)
        }
    }
```

# Advance Usage

If you want your child UIViewController to have knowledge about how much of its view being presented during presentation or is being dismissed during dismisal all you have to do is to make the child UIViewController adopt the ```ScrollPercentageProtocol```. ```ScrollPercentageProtocol``` inherits from ```ChildPageViewControllerProtocol ``` and provides two additional methods.

```
    func isBeingPresentedFromDirection(direction:ScrollDirection,withVisiblePercentage percentage:CGFloat)
    func isBeingDismissedFromDirection(direction:ScrollDirection,withHiddenPercentage percentage:CGFloat)
```

where you will get the information that you need. 
**Note!! This feature is still beta and it doen't always respond**.

All your UIViewController (who has the instance of UIPageViewController) needs to do is create an instance of ```PageViewControllerScrollViewDelegate``` and pass as argument the instance of ```PageViewControllerDatasource```.

```
    var scrollViewDelegate:PageViewControllerScrollViewDelegate<pageFactory,EnhancedChildViewController>?
```

```
    override func viewDidLoad() {
        super.viewDidLoad()
        ..
        ..
        scrollViewDelegate = PageViewControllerScrollViewDelegate(pageViewControllerDatasource:datasource!)
    }
```

# Licence

```PageViewControllerKit``` is being provided under [MIT Licence][MIT].



[MIT]:<https://opensource.org/licenses/MIT>

>Copyright © 2016-present Panagiotis Sartzetakis
