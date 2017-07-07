//
//  PHPieceCell.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHPieceCell: UITableViewCell, PHCourseCategoryColoredView {
    
    @IBOutlet weak var pieceContentView: UIView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    // MARK: - Animation
    func runAnimation(_ iconImagePath: String?) {
        
        self.runInputAnimation(iconImagePath)
        self.runAppearanceAnimation()
    }
    
    func runAppearanceAnimation() {
        
        self.contentView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 1.0
        }) 
    }
    
    func runInputAnimation(_ iconImagePath: String?) {
        // Override here
    }
    
    // MARK: - PHCourseCategoryColoredView
    func setCategoryColor(_ category: PHCourseCategory) {
        // Override here
    }
}
