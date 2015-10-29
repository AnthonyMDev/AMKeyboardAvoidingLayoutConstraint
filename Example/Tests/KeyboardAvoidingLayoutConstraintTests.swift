//
//  KeyboardAvoidingLayoutConstraintTests.swift
//  AMKeyboardAvoidingLayoutConstraint
//
//  Created by Anthony Miller on 10/29/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest

import Nimble

import AMKeyboardAvoidingLayoutConstraint

class KeyboardAvoidingLayoutConstraintTests: XCTestCase {
  
  var sut: KeyboardAvoidingLayoutConstraint!
  
  var viewController: UIViewController!
  
  var window: UIWindow!
  
  override func setUp() {
    super.setUp()
  
    window = UIApplication.sharedApplication().keyWindow
    viewController = UIViewController(nibName: nil, bundle: nil)
    let view = UIView(frame: CGRectMake(0, 0, 100, 100))
    viewController.view.addSubview(view)
    sut = KeyboardAvoidingLayoutConstraint(item: view,
      attribute: .Bottom,
      relatedBy: .Equal,
      toItem: viewController.bottomLayoutGuide,
      attribute: .Top,
      multiplier: 1.0,
      constant: 50.0)
    viewController.view.addConstraint(sut)
    
    window.rootViewController = viewController
    window.addSubview(view)
    viewController.loadView()
    sut.awakeFromNib()
    window.makeKeyAndVisible()
  }
  
  override func tearDown() {
    super.tearDown()
    
    sut = nil
  }
  
  /*
  * MARK: Show/Hide Keyboard - Tests
  */
  
  func test__keyboardWillShow__setsMessageTextViewBottomSpaceConstraintToOriginalPlusKeyboardHeight() {
    // given
    let keyboardHeight: CGFloat = 10
    let expected = sut.constant + keyboardHeight
    let keyboardFrame = CGRectMake(0, 0, 0, keyboardHeight)
    
    // when
    NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillShowNotification,
      object: window,
      userInfo: [UIKeyboardFrameEndUserInfoKey: NSValue(CGRect: keyboardFrame)])
    
    // then
    expect(self.sut.constant).to(equal(expected))
  }
  
  func test__keyboardWillShow__givenHasTabBar_setsMessageTextViewBottomSpaceConstraintToOriginalPlusKeyboardHeightMinusTabBarHeight() {
    // given
    let tabBarVC = UITabBarController()
    window.rootViewController = tabBarVC
    tabBarVC.setViewControllers([viewController], animated: false)
    
    let keyboardHeight: CGFloat = 10
    let expected = sut.constant + keyboardHeight - tabBarVC.tabBar.frame.height
    let keyboardFrame = CGRectMake(0, 0, 0, keyboardHeight)
    
    // when
    NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillShowNotification,
      object: window,
      userInfo: [UIKeyboardFrameEndUserInfoKey: NSValue(CGRect: keyboardFrame)])
    
    // then
    expect(self.sut.constant).to(equal(expected))
  }
  
  func test__keyboardWillShow__givenHasToolbar_setsMessageTextViewBottomSpaceConstraintToOriginalPlusKeyboardHeightMinusToolbarHeight() {
    // given
    window.rootViewController = nil
    viewController.toolbarItems = [UIBarButtonItem(barButtonSystemItem: .Refresh, target: nil, action: nil)]
    let navVC = UINavigationController(rootViewController: viewController)
    navVC.toolbarHidden = false
    window.rootViewController = navVC
    
    let keyboardHeight: CGFloat = 10
    let expected = sut.constant + keyboardHeight - navVC.toolbar.frame.height
    let keyboardFrame = CGRectMake(0, 0, 0, keyboardHeight)
    
    // when
    NSNotificationCenter.defaultCenter().postNotificationName(UIKeyboardWillShowNotification,
      object: window,
      userInfo: [UIKeyboardFrameEndUserInfoKey: NSValue(CGRect: keyboardFrame)])
    
    // then
    expect(self.sut.constant).to(equal(expected))
  }

}
