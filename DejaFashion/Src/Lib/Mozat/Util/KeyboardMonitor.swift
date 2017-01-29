//
//  KeyboardMonitor.swift
//  DejaFashion
//
//  Created by DanyChen on 3/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol KeyboardMonitorDelegate : NSObjectProtocol {
    
    func keyboardWillShow(keyboardHeight : CGFloat, animationDuration : CGFloat)
    
    func keyboardWillHide(keyboardHeight : CGFloat, animationDuration : CGFloat)
}

class KeyboardMonitor: NSObject {
    weak var delegate : KeyboardMonitorDelegate?
    
    func start() {
        end()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardMonitor.keyBoardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardMonitor.keyBoardWillHidden(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyBoardWillShow(notification : NSNotification) {
        if let config = extractValueFromNSNotification(notification) {
            self.delegate?.keyboardWillShow(config.height, animationDuration: config.animationDuration)
        }
    }
    
    func keyBoardWillHidden(notification : NSNotification) {
        if let config = extractValueFromNSNotification(notification) {
            self.delegate?.keyboardWillHide(config.height, animationDuration: config.animationDuration)
        }
    }
    
    private func extractValueFromNSNotification(notification : NSNotification) -> (height : CGFloat, animationDuration : CGFloat)? {
        if let userInfo = notification.userInfo {
            if let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = value.CGRectValue()
                if let interval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
                    return (height : frame.height, animationDuration: CGFloat(interval.floatValue))
                }
            }
        }
        return nil
    }
    
    func end() {
        self.delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

}
