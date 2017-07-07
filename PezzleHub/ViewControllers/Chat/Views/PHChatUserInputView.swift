//
//  PHChatUserInputView.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/13/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHChatUserInputView: UIView {
    
    enum PlayButtonAppearance {
        
        case normal
        case bubble
        
        var image: UIImage? {
            
            switch self {
            case .normal:
                return UIImage(named: "play_icon")!
            case .bubble:
                return nil
            }
        }
        
        var title: String? {
            
            switch self {
            case .normal:
                return nil
            case .bubble:
                return "..."
            }
        }

        var backgroundImage: UIImage? {
            
            switch self {
            case .normal:
                return nil
            case .bubble:
                return UIImage(named: "bubble_user")!
            }
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet var viewAllButtonTopConstraint: NSLayoutConstraint!
    
    fileprivate var isHeartBeatRunning = false

    var playButtonAppearance = PlayButtonAppearance.normal {
        didSet {
            
            if self.playButtonAppearance == oldValue {
                return
            }
            
            self.playButton.setImage(self.playButtonAppearance.image, for: UIControlState())
            self.playButton.setTitle(self.playButtonAppearance.title, for: UIControlState())
            self.playButton.setBackgroundImage(self.playButtonAppearance.backgroundImage, for: UIControlState())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.setUpReplayButton()
    }
    /*
    private func setUpReplayButton() {
        
        // UIButton.imageEdgeInsets doesn't auto-resize so use imageView
        let replayIcon = UIImage(named: "replay_icon")!
        
        var frame = CGRect.zero
        frame.origin.x = self.replayButton.frame.size.width - replayIcon.size.width - 14.0
        frame.origin.y = (self.replayButton.frame.size.height - replayIcon.size.height) / 2.0
        frame.size = replayIcon.size
        
        let imageView = UIImageView(frame: frame)
        imageView.image = replayIcon
        imageView.contentMode = .ScaleAspectFit
        imageView.autoresizingMask = [ .FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin ]
        
        self.replayButton.addSubview(imageView)
    }
 */
}

// MARK: - View Appearances
extension PHChatUserInputView {
    
    func viewAllButtonHidden(_ hidden: Bool, animated: Bool) {
        
        let isHidden = self.constraints.contains(self.viewAllButtonTopConstraint)
        
        if hidden == isHidden {
            return
        }
        
        let animations = { () -> Void in
            
            self.layoutIfNeeded()
        }
        let completion = { (flag: Bool) -> Void in
        }
        
        if hidden {
            
            self.addConstraint(self.viewAllButtonTopConstraint)
            
        } else {
            
            self.removeConstraint(self.viewAllButtonTopConstraint)
        }
        
        if animated {
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: animations, completion: completion)
            
        } else {
            
            animations()
            completion(true)
        }
    }

    func playButtonHidden(_ hidden: Bool, animated: Bool) {
        
        self.viewHidden(hidden, animated: animated, view: self.playButton)
    }
    
    func completeButtonHidden(_ hidden: Bool, animated: Bool) {
        
        self.viewHidden(hidden, animated: animated, view: self.completeButton)
    }

    func completeButtonEnable(_ enable: Bool) {
        
        self.completeButton.isEnabled = enable
        if enable {
            self.completeButton.backgroundColor = UIColor(decimalRed: 51, green: 51, blue: 51)
        } else {
            self.completeButton.backgroundColor = UIColor(decimalRed: 222, green: 222, blue: 222)
        }
    }

    fileprivate func viewHidden(_ hidden: Bool, animated: Bool, view: UIView) {
        
        let toAlpha: CGFloat = hidden ? 0.0 : 1.0
        let fromAlpha: CGFloat = 1.0 - toAlpha
        
        if view.isHidden == hidden && view.alpha == toAlpha {
            return
        }
        
        let animations = { () -> Void in
            
            view.alpha = toAlpha
        }
        let completion = { (flag: Bool) -> Void in
            
            view.isHidden = hidden
        }
        
        view.alpha = fromAlpha
        view.isHidden = !hidden
        
        if animated {
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: animations, completion: completion)
            
        } else {
            
            animations()
            completion(true)
        }
    }
}

// MARK: - PlayButton Heartbeat Animation
extension PHChatUserInputView {
    
    func startHeartbeat(_ zoomFlag: Bool = true) {
        
        if self.isHeartBeatRunning {
            return
        }
        
        // 拡大時の倍率
        let zoomMag: CGFloat = 1.2
        
        // アニメーションの間隔（秒）
        let duration: TimeInterval = 0.2
        
        self.isHeartBeatRunning = true
        
        let mag: CGFloat = zoomFlag ? zoomMag : 1.0
        
        let delay: TimeInterval = zoomFlag ? 0.8 : 0.0
        let options: UIViewAnimationOptions = .allowUserInteraction
        let anim = {
            self.playButton.transform = CGAffineTransform(scaleX: mag, y: mag)
        }
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: anim) { flag in
            
            if self.isHeartBeatRunning {
                
                self.isHeartBeatRunning = false
                self.startHeartbeat(!zoomFlag)
            }
        }
    }
    
    func stopHeartbeat() {
        
        self.isHeartBeatRunning = false
        
        self.playButton.layer.removeAllAnimations()
        self.playButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
}
