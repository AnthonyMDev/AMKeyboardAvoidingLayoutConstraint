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
  
    window = UIApplication.shared.keyWindow
    viewController = UIViewController(nibName: nil, bundle: nil)
    let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100)))
    viewController.view.addSubview(view)
    sut = KeyboardAvoidingLayoutConstraint(item: view,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: viewController.bottomLayoutGuide,
      attribute: .top,
      multiplier: 1.0,
      constant: 50.0)
    sut.pinnedView = view
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
    let keyboardFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: keyboardHeight))
    
    // when
    NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillShow,
      object: window,
      userInfo: [UIKeyboardFrameEndUserInfoKey: NSValue(cgRect: keyboardFrame)])
    
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
    let keyboardFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: keyboardHeight))
    
    // when
    NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillShow,
      object: window,
      userInfo: [UIKeyboardFrameEndUserInfoKey: NSValue(cgRect: keyboardFrame)])
    
    // then
    expect(self.sut.constant).to(equal(expected))
  }
  
  func test__keyboardWillShow__givenHasToolbar_setsMessageTextViewBottomSpaceConstraintToOriginalPlusKeyboardHeightMinusToolbarHeight() {
    // given
    window.rootViewController = nil
    viewController.toolbarItems = [UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)]
    let navVC = UINavigationController(rootViewController: viewController)
    navVC.isToolbarHidden = false
    window.rootViewController = navVC
    
    let keyboardHeight: CGFloat = 10
    let expected = sut.constant + keyboardHeight - navVC.toolbar.frame.height
    let keyboardFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: keyboardHeight))
    
    // when
    NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillShow,
      object: window,
      userInfo: [UIKeyboardFrameEndUserInfoKey: NSValue(cgRect: keyboardFrame)])
    
    // then
    expect(self.sut.constant).to(equal(expected))
  }

}
