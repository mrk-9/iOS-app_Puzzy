//
//  PHOwnerPieceCell.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/29/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import GVUserDefaults

class PHOwnerPieceCell: PHPieceCell {

    fileprivate var inputAnimationView: PHInputAnimationView?
    fileprivate var inputAnimationContainerView: UIImageView?
    fileprivate var ownerIconView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    fileprivate func setUpInputAnimationView(_ iconImagePath: String?) {
        
        // Maybe I should rewrite this using xib
        self.inputAnimationContainerView = UIImageView(frame: self.pieceContentView.bounds)        
        self.inputAnimationContainerView!.image = self.bubbleImageView.image

        self.inputAnimationContainerView!.isUserInteractionEnabled = false
        self.inputAnimationContainerView!.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.inputAnimationContainerView!.backgroundColor = UIColor.clear
        self.inputAnimationContainerView!.isHidden = true

        let ownerIconSize: CGFloat = 32.0
        var animationViewFrame = self.inputAnimationContainerView!.bounds
        animationViewFrame.origin.x = 12.0 + ownerIconSize
        animationViewFrame.size.width -= animationViewFrame.origin.x
        
        self.inputAnimationView = PHInputAnimationView(frame: animationViewFrame)
        
        self.inputAnimationView!.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.inputAnimationView!.backgroundColor = UIColor.clear
        
        self.inputAnimationView!.clipsToBounds = true
        self.inputAnimationView!.layer.cornerRadius = 40.0
        
        self.pieceContentView.addSubview(self.inputAnimationContainerView!)
        self.inputAnimationContainerView!.addSubview(self.inputAnimationView!)

        if let iconImagePath = iconImagePath {
            
            let ownerIconFrame = CGRect(x: 4.0, y: -ownerIconSize * 0.3, width: ownerIconSize, height: ownerIconSize)
            self.ownerIconView = UIImageView(frame: ownerIconFrame)
            
            self.ownerIconView!.clipsToBounds = true
            self.ownerIconView!.layer.cornerRadius = ownerIconSize / 2.0
            self.ownerIconView!.layer.borderColor = UIColor.white.cgColor
            self.ownerIconView!.layer.borderWidth = 2.0
            
            self.ownerIconView!.setImageWithPlaceholder(iconImagePath)
            self.ownerIconView!.autoresizingMask = [ .flexibleBottomMargin, .flexibleRightMargin ]
            self.ownerIconView!.backgroundColor = UIColor.white
            
            self.inputAnimationContainerView!.addSubview(self.ownerIconView!)
        }
    }
    
    fileprivate func tearDownInputAnimationView() {
        
        self.ownerIconView?.removeFromSuperview()
        
        self.inputAnimationView!.removeFromSuperview()
        
        self.inputAnimationContainerView!.removeFromSuperview()
    }
    
    override func runInputAnimation(_ iconImagePath: String?) {

        let userDefaults = GVUserDefaults.standard()
        let pieceAppearanceInterval = TimeInterval((userDefaults?.displaySpeed)!)
        if pieceAppearanceInterval < 0.7 {
            return
        }

        if let _ = self.inputAnimationView {
            
            self.tearDownInputAnimationView()
        }

        self.setUpInputAnimationView(iconImagePath)

        self.inputAnimationContainerView!.isHidden = false
        self.inputAnimationContainerView!.alpha = 1.0
        self.inputAnimationView!.startAnimating()
        
        performAfterDelay(pieceAppearanceInterval - 0.4) {
            
            self.inputAnimationView?.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.inputAnimationContainerView?.alpha = 0.0
                
            }, completion: { (completed) in
                
                self.inputAnimationContainerView?.isHidden = true
                self.inputAnimationContainerView?.alpha = 1.0
                
                self.tearDownInputAnimationView()
            })
        }
    }
}
