//
//  TermsAndConditionsCell.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHCourseRoomChapterCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberLabelBorderView: UIView!
    @IBOutlet weak var numberBackgroundLabel: UILabel!
    @IBOutlet weak var numberBackgroundLabelBorderView: UIView!
    @IBOutlet weak var numberLabelContainerView: UIView!
    @IBOutlet fileprivate weak var numberContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var numberLabelCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var selectedCornerView: UIView!
    @IBOutlet fileprivate weak var selectedCenterView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var chapterSelected = false {
        didSet {
            
            if self.chapterSelected == oldValue {
                return
            }
            
            if self.chapterSelected {
                self.numberLabelCenterConstraint.constant = (self.frame.size.width - self.numberLabel.frame.size.width) / 2.0
            } else {
                self.numberLabelCenterConstraint.constant = 0
            }
            UIView.animate(withDuration: defaultAnimationDuration, animations: { () -> Void in
                self.layoutIfNeeded()
                self.selectedCenterView.alpha = self.chapterSelected ? 1.0 : 0.0
            }) 
        }
    }
    
    func setProgress(_ progress: Float) {
        
        assert(progress >= 0.0 && progress <= 1.0, "progress value must be between 0.0 and 1.0")
        
        let height = self.numberLabelContainerView.frame.size.width * CGFloat(progress)
        self.numberContainerViewHeightConstraint.constant = height
        self.layoutIfNeeded()
    }
}

extension PHCourseRoomChapterCell: PHCourseCategoryColoredView {

    func setCategoryColor(_ category: PHCourseCategory) {
        self.setCategoryColor(category, chapterStatus: .notDelivered)
    }
    
    func setCategoryColor(_ category: PHCourseCategory, chapterStatus: PHChapterStatus) {
        
        let categoryColor = category.color
        let categoryLightColor = category.lightColor
        
        self.selectedCenterView.backgroundColor = categoryColor
        
        switch chapterStatus {
        case .delivered:
            self.numberLabelBorderView.layer.borderColor = categoryColor.cgColor
            self.numberLabel.backgroundColor = categoryColor
            self.numberLabel.textColor = UIColor.white

            self.numberBackgroundLabelBorderView.layer.borderColor = categoryColor.cgColor
            self.numberBackgroundLabelBorderView.backgroundColor = categoryLightColor
            self.numberBackgroundLabel.textColor = categoryColor

        case .next:
            self.numberLabelBorderView.layer.borderColor = categoryColor.cgColor
            self.numberLabel.backgroundColor = categoryLightColor
            self.numberLabel.textColor = categoryColor

            self.numberBackgroundLabelBorderView.layer.borderColor = categoryColor.cgColor
            self.setProgress(1.0)
                        
        case .notDelivered:
            self.numberLabelBorderView.layer.borderColor = categoryLightColor.cgColor
            self.numberLabel.backgroundColor = categoryLightColor
            self.numberLabel.textColor = UIColor.white

            self.numberBackgroundLabelBorderView.layer.borderColor = categoryLightColor.cgColor
            self.setProgress(1.0)
        }
    }
}
