# KeyboardHandler
Simple helper to handle iOS keyboard events

## Example
```swift
class MyViewController: UIViewController {
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
	private let keyboardHandler = KeyboardHandler()
	...
```

```swift
...
override func viewDidLoad() {
	super.viewDidLoad()
	
	keyboardHandler.view = self.view
	keyboardHandler.deactivate(constraint: topConstraint)
	keyboardHandler.liftUp(constraint: bottomConstraint, multiply: 1.0, plus: -62.0)
	keyboardHandler.hideKeyboardByTapOnView()
}
...
```

## Available methods

```swift
public func activate(constraint: NSLayoutConstraint)
public func deactivate(constraint: NSLayoutConstraint)
public func liftUp(view: UIView)
public func liftUp(constraint: NSLayoutConstraint, multiply: Double = 1.0, plus: Double = 0.0)
public func hideKeyboardByTap(onView view: UIView)
```