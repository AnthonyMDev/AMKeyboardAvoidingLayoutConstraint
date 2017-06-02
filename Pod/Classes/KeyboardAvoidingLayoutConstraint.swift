//
//  KeyboardAvoidingLayoutConstraint.swift
//  AMKeyboardAvoidingLayoutConstraint
//
//  Created by Anthony Miller on 10/29/15.
//

import UIKit

/// A layout constraint subclass that can automatically avoid the keyboard when it is shown.
///
/// When the keyboard is shown, the constant will be adjusted to adjust the `avoidingView` away from the keyboard.
public final class KeyboardAvoidingLayoutConstraint: NSLayoutConstraint {
    
    /*
     *  MARK: - Instance Variables
     */
    
    /// The view that the constraint will make avoid the keyboard. This must be set prior to loading the view.
    @IBOutlet public var avoidingView: UIView!
    
    /// Denotes if the constraint is currently avoiding the keyboard.
    public var isAvoidingKeyboard: Bool {
        get {
            return _isAvoidingKeyboard
        }
        set {
            newValue ? startAvoidingKeyboard() : stopAvoidingKeyboard()
        }
    }
    
    private var _isAvoidingKeyboard = false
    
    private var originalConstant: CGFloat!
    
    private var isRotating = false
    
    /*
     *  MARK: - Object Lifecycle
     */
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
       startAvoidingKeyboard()
    }

    /// This method must be called for keyboard avoiding behavior to occur. If the
    /// constraint is created via a storyboard or nib, this will be called automatically
    /// during `awakeFromNib()`. If the constraint is created programatically, this must be
    /// called manually.
    public func startAvoidingKeyboard() {
        if _isAvoidingKeyboard { return }
        
        originalConstant = constant
        registerForKeyboardNotifications()
        _isAvoidingKeyboard = true
    }
    
    public func stopAvoidingKeyboard() {
        if !_isAvoidingKeyboard { return }
        
        NotificationCenter.default.removeObserver(self)
        _isAvoidingKeyboard = false
    }
    
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange(_:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willRotate(_:)),
                                               name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didRotate(_:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func willRotate(_ notification: Notification) {
        isRotating = true
    }
    
    func didRotate(_ notification: Notification) {
        isRotating = false
    }
    
    /*
     * MARK: - Show/Hide Keyboard
     */
    
    func keyboardWillChange(_ notification: Notification) {
        guard let newConstant = newConstantForKeyboardChange(notification),
            !isRotating &&
            newConstant != self.constant else { return }
        
        let viewToLayout = avoidingView.superview ?? avoidingView
        
        viewToLayout?.layoutIfNeeded()
        
        let duration: TimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double) ?? 0.2
        
        UIView.animate(withDuration: duration,
                       delay: 0.0, options: animationOptions(notification),
                       animations: { [weak self] in
                        self?.constant = newConstant
                        viewToLayout?.layoutIfNeeded()
        })

    }
    
    private func newConstantForKeyboardChange(_ notification: Notification) -> CGFloat? {
        guard let endFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let keyboardFrame = UIApplication.shared.keyWindow?.convert(endFrame, to: nil) else {
                return nil
        }
        
        if keyboardFrame.origin.y == UIScreen.main.bounds.height {
            return originalConstant
        }
        
        let originInWindow = avoidingView.convert(avoidingView.bounds.origin, to: nil)
        let heightDifference = keyboardFrame.origin.y - (originInWindow.y + avoidingView.frame.height) - originalConstant
        
        return heightDifference != 0 ? constant - heightDifference : nil
    }
    
    private func animationOptions(_ notification: Notification) -> UIViewAnimationOptions {
        var options: UIViewAnimationOptions = .beginFromCurrentState
        
        if let animationCurve = UIViewAnimationCurve(rawValue: (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? Int) ?? 0) {
        
            switch animationCurve {
            case .easeIn: options.insert(.curveEaseIn)
            case .easeOut: options.insert(.curveEaseOut)
            case .easeInOut: options.insert(.curveEaseInOut)
            case .linear: options.insert(.curveLinear)
            }
        }
        
        return options
    }
    
}
