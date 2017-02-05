import UIKit

final public class KeyboardHandler {
    private var constraintsToActivate: [NSLayoutConstraint] = []
    private var constraintsToDeactivate: [NSLayoutConstraint] = []
    private var viewsToLiftUp: [UIView] = []
    private var constraintLiftings: [ConstraintLifting] = []
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public
    
    /// Main view (e.g. viewController.view)
    /// Set this to correctly animate layout when keyboard appears/disappears
    public var view: UIView? = nil
    
    /// Activate constraint when keyboard appears
    /// - Parameter constraint: constraint to activate
    ///
    /// - Warning: Set `view` property to correctly animate layout
    public func activate(constraint: NSLayoutConstraint) {
        constraintsToActivate.append(constraint)
    }
    
    /// Deactivate constraint when keyboard appears
    /// - Parameter constraint: constraint to deactivate
    ///
    /// - Warning: Set `view` property to correctly animate layout
    public func deactivate(constraint: NSLayoutConstraint) {
        constraintsToDeactivate.append(constraint)
    }
    
    /// Lift up the view when keyboard appears
    /// - Parameter view: View to lift up
    ///
    /// - Note: Sets bounds under the hood
    /// - Warning: Set `view` property to correctly animate layout
    public func liftUp(view: UIView) {
        viewsToLiftUp.append(view)
    }
    
    /// Lift up the view specified in `view` property
    ///
    /// - Warning: Set `view` property to correctly animate layout
    /// - SeeAlso: `view`
    public func liftUpView() {
        assert(view != nil, "Must specify `view` property first")
        liftUp(view: view!)
    }
    
    /// Lift up constraint (e.g. bottom constraint)
    /// - Parameter constraint: constraint to lift up
    /// - Parameter multiply: Multipler that is applied to keyboard height
    /// - Parameter plus: Constant that is added to keyboard height (may be negative)
    ///
    /// - Note: Sets constraint.constant under the hood and remembers initial value
    /// - Warning: Set `view` property to correctly animate layout
    public func liftUp(constraint: NSLayoutConstraint, multiply: Double = 1.0, plus: Double = 0.0) {
        constraintLiftings.append(
            ConstraintLifting(
                constraint: constraint,
                originalConstant: constraint.constant,
                multiplier: multiply,
                plus: plus))
    }
    
    /// Hide keyboard by tapping on view (e.g. background view)
    /// - Parameter view: View to catch tapping on
    public func hideKeyboardByTap(onView view: UIView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    /// Hide keyboard by tapping on view specified in `view` property
    ///
    /// - SeeAlso: `view`
    public func hideKeyboardByTapOnView() {
        assert(view != nil, "Must specify `view` property first")
        hideKeyboardByTap(onView: view!)
    }
    
    // MARK: - Private
    
    @objc private func didTapOnView(gestureRecognizer: UITapGestureRecognizer) {
        gestureRecognizer.view?.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        for constraint in constraintsToActivate {
            constraint.isActive = true
        }
        
        for constraint in constraintsToDeactivate {
            constraint.isActive = false
        }
        
        for view in viewsToLiftUp {
            var bounds = view.bounds
            bounds.origin.y = keyboardFrame.size.height
            
            UIView.animate(withDuration: animationDuration) {
                view.bounds = bounds
            }
        }
        
        for constraintLifting in constraintLiftings {
            constraintLifting.constraint.constant = constraintLifting.originalConstant
                + keyboardFrame.size.height
                * CGFloat(constraintLifting.multiplier)
                + CGFloat(constraintLifting.plus)
        }
        
        if let view = view {
            UIView.animate(withDuration: animationDuration) {
                view.layoutIfNeeded()
            }
        }
        else {
            debugPrint("KeyboardHandler.view is not specified so layout will not be animated.")
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        for constraint in constraintsToActivate {
            constraint.isActive = false
        }
        
        for constraint in constraintsToDeactivate {
            constraint.isActive = true
        }
        
        for view in viewsToLiftUp {
            var bounds = view.bounds
            bounds.origin.y = 0
            
            UIView.animate(withDuration: animationDuration) {
                view.bounds = bounds
            }
        }
        
        for constraintLifting in constraintLiftings {
            constraintLifting.constraint.constant = constraintLifting.originalConstant
        }
        
        if let view = view {
            UIView.animate(withDuration: animationDuration) {
                view.layoutIfNeeded()
            }
        }
        else {
            debugPrint("KeyboardHandler.view is not specified so layout will not be animated.")
        }
    }
    
    private struct ConstraintLifting {
        let constraint: NSLayoutConstraint
        let originalConstant: CGFloat
        let multiplier: Double
        let plus: Double
    }
}
