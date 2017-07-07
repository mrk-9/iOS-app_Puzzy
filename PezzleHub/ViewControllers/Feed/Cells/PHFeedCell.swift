//
//  TermsAndConditionsCell.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHFeedCellDelegate {
    func pushDetailView(_ cell: PHFeedCell)
}

class PHFeedCell: UITableViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoShadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var newBadgeView: UIView!
    @IBOutlet weak var separatorView: UIView!

    @IBOutlet weak var chapterProgress: UIProgressView!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var finishReadingBadge: UIImageView!

    class var defaultRowHeight: CGFloat {
        return 80.0
    }
    
    var originalCenter = CGPoint()
    var firePushEvent = false
    var delegate: PHFeedCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.photoView.clipsToBounds = true
        self.photoView.layer.cornerRadius = self.photoView.frame.size.width / 2.0
        self.photoShadowView.clipsToBounds = true
        self.photoShadowView.layer.cornerRadius = self.photoView.frame.size.width / 2.0

        self.chapterProgress.clipsToBounds = true
        self.chapterProgress.layer.cornerRadius = 2
        self.deliveryDateLabel.clipsToBounds = true
        self.deliveryDateLabel.layer.cornerRadius = 8
        self.deliveryDateLabel.textColor = UIColor.white
        
        // add a pan recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action:  #selector(handlePanGesture(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    //MARK: - horizontal pan gesture methods
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {

        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
            
        } else if recognizer.state == .changed {
            
            let translation = recognizer.translation(in: self)
            center =   CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // has the user dragged the cell far enough to initiate a push?
            firePushEvent = frame.origin.x < -frame.size.width / 4.0
            if firePushEvent && self.delegate != nil {
                recognizer.isEnabled = false
                self.delegate?.pushDetailView(self)
                
                let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                           width: bounds.size.width, height: bounds.size.height)
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame}, completion: { (flag: Bool) -> Void in
                    recognizer.isEnabled = true
                })
            }
        } else if recognizer.state == .ended {

            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if !firePushEvent {
                // if the item is not being dragged, snap back to the original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            let vel = panGestureRecognizer.velocity(in: self)
            if vel.x > 0 {
                // user dragged towards the right
                return false
            }

            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}

extension PHFeedCell: PHCourseCategoryColoredView {
    
    func setCategoryColor(_ category: PHCourseCategory) {
        
        let categoryColor = category.color
        let lightCategoryColor = category.lightColor
        
        self.contentView.backgroundColor = categoryColor
        self.photoShadowView.backgroundColor = lightCategoryColor
        self.separatorView.backgroundColor = lightCategoryColor
    }
}
