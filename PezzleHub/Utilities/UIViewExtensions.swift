//
//  UIViewExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

extension UIView {
    
    func removeGestureRecognizers() {
        
        guard let gestureRecognizers = self.gestureRecognizers else {
            return
        }
        
        for recognizer in gestureRecognizers {
            self.removeGestureRecognizer(recognizer)
        }
    }
    
    internal class func instantiateFromNib<T> () -> T {
        
        let className: String = stringFromClass(self)
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)![0] as! T
    }
    
    func setUpSubviewFromNib() {
        
        let className = stringFromClass(type(of: self))
        let view = Bundle.main.loadNibNamed(className, owner: self, options: nil)?.first as! UIView

        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.bounds = view.bounds
        self.addSubview(view)
    }
}
