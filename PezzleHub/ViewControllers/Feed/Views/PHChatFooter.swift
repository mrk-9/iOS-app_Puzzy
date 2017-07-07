//
//  File.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHChatFooter: UIView {
    
    fileprivate func customInit() {
        let view = Bundle.main.loadNibNamed("PHChatFooter", owner: self, options: nil)?.first as! UIView
        self.bounds = view.bounds
        self.addSubview(view)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init () {
        super.init(frame: CGRect.zero)
        self.customInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    
}
