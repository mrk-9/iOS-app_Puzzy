//
//  PieceBasicDetailsView.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHOwnerDetailsView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var ownerDescriptionLabel: UILabel!
    @IBOutlet weak var ownerBottomView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frame.size.height = self.ownerBottomView.frame.size.height + self.ownerBottomView.frame.origin.y
    }
    
    fileprivate func customInit() {
        
        self.backgroundColor = UIColor.clear
        
        let view = Bundle.main.loadNibNamed("PHOwnerDetailsView", owner: self, options: nil)?.first as! UIView
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
