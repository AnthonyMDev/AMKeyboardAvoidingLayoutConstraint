//
//  KeyboardAvoidingLayoutConstraint.swift
//  AMKeyboardAvoidingLayoutConstraint
//
//  Created by Anthony Miller on 10/29/15.
//

import UIKit

open class KeyboardAvoidingLayoutConstraint: NSLayoutConstraint {
  
  /*
  *  MARK: - Instance Variables
  */
  
  fileprivate var originalConstant: CGFloat!
  
  @IBOutlet open var pinnedView: UIView!
  
  /*
  *  MARK: - Object Lifecycle
  */
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
    originalConstant = constant
    
    registerForKeyboardNotifications()
  }
  
  fileprivate func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(self,
        selector: #selector(KeyboardAvoidingLayoutConstraint.keyboardWillShow(_:)),
        name: NSNotification.Name.UIKeyboardWillShow,
        object: pinnedView.window)
    
    NotificationCenter.default.addObserver(self,
        selector: #selector(KeyboardAvoidingLayoutConstraint.keyboardWillHide(_:)),
        name: NSNotification.Name.UIKeyboardWillHide,
        object: pinnedView.window)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  /*
  * MARK: - Show/Hide Keyboard
  */
  
  func keyboardWillShow(_ notification: Notification) {
    adjustConstantForKeyboard(true, notification: notification)
  }
  
  func keyboardWillHide(_ notification: Notification) {
    adjustConstantForKeyboard(false, notification: notification)
  }
  
  fileprivate func adjustConstantForKeyboard(_ keyboardWillShow: Bool, notification: Notification) {
    if let height = heightToAdjustForKeyboard(notification) {
      pinnedView.superview?.layoutIfNeeded()
      
      if keyboardWillShow {
        constant = originalConstant + height
      } else {
        constant = originalConstant
      }
     
        let animationDuration: TimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double) ?? 0.2
        
      UIView.animate(withDuration: animationDuration) { [weak self] () -> Void in
        self?.pinnedView.superview?.layoutIfNeeded()
      }
    }
  }
  
  fileprivate func heightToAdjustForKeyboard(_ notification: Notification) -> CGFloat? {
    if let value = (notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardFrame = value.cgRectValue
      var height = keyboardFrame.height
      
      if let tabBarHeight = findTabBarInWindow()?.frame.height {
        height -= tabBarHeight
      }
      
      if let navVC = pinnedView.window?.rootViewController as? UINavigationController , navVC.isToolbarHidden == false {
        height -= navVC.toolbar.frame.height
      }
      
      return height
    }
    return nil
  }
  
  fileprivate func findTabBarInWindow() -> UITabBar? {
    if let tabBarVC = pinnedView.window?.rootViewController as? UITabBarController {
      return tabBarVC.tabBar
      
    }
    return nil
  }
  
}

