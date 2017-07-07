//
//  PHURLPieceCell.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHURLPieceCell: PHTextPieceCell {

    @IBOutlet weak var webImageView: UIImageView!
    @IBOutlet weak var webImageMaskView: UIView!

//    @IBOutlet weak var webImageViewHeightConstraint: NSLayoutConstraint!  // TODO: Create design for when no image

    override func awakeFromNib() {
        super.awakeFromNib()

        self.webImageView.layer.borderColor = UIColor.white.cgColor
        self.webImageMaskView.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - PHCourseCategoryColoredView
    override func setCategoryColor(_ category: PHCourseCategory) {
        
        let bubbleColor = category.lightColor
        
        self.webImageView.layer.borderColor = bubbleColor.cgColor
        self.webImageMaskView.layer.borderColor = bubbleColor.cgColor
        self.bubbleImageView.image = self.bubbleImageView.image!.coloredImage(bubbleColor)
    }
}
