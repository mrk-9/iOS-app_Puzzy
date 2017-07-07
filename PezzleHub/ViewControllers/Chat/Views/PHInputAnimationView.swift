//
//  PHInputAnimationView.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/29/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import GVUserDefaults

class PHInputAnimationView: UILabel {

    var timer: Timer?

    // MARK: - Lifecycle
    override var isHidden: Bool {
        didSet {
            if isHidden {
                self.stopAnimating()
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setUpAnimationView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpAnimationView() {
        
        self.text = ""
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if self.superview == nil {
            self.stopAnimating()
        }
    }
    
    // MARK: - Actions
    func startAnimating() {
                
        self.isHidden = false
        
        if self.timer == nil {

            let userDefaults = GVUserDefaults.standard()
            let pieceAppearanceInterval = TimeInterval((userDefaults?.displaySpeed)!)

            let interval = pieceAppearanceInterval / 5.0
            self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(PHInputAnimationView.inputAnimation), userInfo: nil, repeats: true)
        }
    }
    
    func stopAnimating() {
        
        self.text = ""
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: - Animation
    @objc fileprivate func inputAnimation() {
        
        var animationText = self.text ?? ""
        animationText += "・"
        if animationText.characters.count > 5 {
            animationText = "・"
        }
        self.text = animationText
    }
}
