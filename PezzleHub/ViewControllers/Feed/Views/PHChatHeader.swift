//
//  File.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHChatHeader: UIView {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var title = "" {
        didSet {
            titleLabel.text = title
            self.layoutIfNeeded()
            self.frame.size.height = titleLabel.frame.origin.y + titleLabel.frame.height + 12
        }
    }
    
    fileprivate func customInit() {
        let view = Bundle.main.loadNibNamed("PHChatHeader", owner: self, options: nil)?.first as! UIView
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
