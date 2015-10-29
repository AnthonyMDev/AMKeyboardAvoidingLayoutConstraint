//
//  KeyboardAvoidingLayoutConstraint.swift
//  AMKeyboardAvoidingLayoutConstraint
//
//  Created by Anthony Miller on 10/29/15.
//

import UIKit

public class KeyboardAvoidingLayoutConstraint: NSLayoutConstraint {
  
  /*
  *  MARK: - Instance Variables
  */
  
  private var originalConstant: CGFloat!
  
  @IBOutlet public var pinnedView: UIView!
  
  /*
  *  MARK: - Object Lifecycle
  */
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    originalConstant = constant
    
    registerForKeyboardNotifications()
  }
  
  private func registerForKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self,
        selector: "keyboardWillShow:",
        name: UIKeyboardWillShowNotification,
        object: pinnedView.window)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
        selector: "keyboardWillHide:",
        name: UIKeyboardWillHideNotification,
        object: pinnedView.window)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  /*
  * MARK: - Show/Hide Keyboard
  */
  
  func keyboardWillShow(notification: NSNotification) {
    adjustConstantForKeyboard(true, notification: notification)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    adjustConstantForKeyboard(false, notification: notification)
  }
  
  private func adjustConstantForKeyboard(keyboardWillShow: Bool, notification: NSNotification) {
    if let height = heightToAdjustForKeyboard(notification) {
      pinnedView.superview?.layoutIfNeeded()
      
      if keyboardWillShow {
        constant = originalConstant + height
      } else {
        constant = originalConstant
      }
      
      let animationDuration: NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.2
      
      UIView.animateWithDuration(animationDuration) { [weak self] () -> Void in
        self?.pinnedView.superview?.layoutIfNeeded()
      }
    }
  }
  
  private func heightToAdjustForKeyboard(notification: NSNotification) -> CGFloat? {
    if let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardFrame = value.CGRectValue()
      var height = keyboardFrame.height
      
      if let tabBarHeight = findTabBarInWindow()?.frame.height {
        height -= tabBarHeight
      }
      
      if let navVC = pinnedView.window?.rootViewController as? UINavigationController where navVC.toolbarHidden == false {
        height -= navVC.toolbar.frame.height
      }
      
      return height
    }
    return nil
  }
  
  private func findTabBarInWindow() -> UITabBar? {
    if let tabBarVC = pinnedView.window?.rootViewController as? UITabBarController {
      return tabBarVC.tabBar
      
    }
    return nil
  }
  
}

