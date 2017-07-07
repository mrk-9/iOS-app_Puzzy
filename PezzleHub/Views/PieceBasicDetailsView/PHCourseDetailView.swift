//
//  PieceBasicDetailsView.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHCourseDetailView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageShadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.setUpSubviewFromNib()
    }
}

extension PHCourseDetailView: PHCourseCategoryColoredView {
    
    func setCategoryColor(_ category: PHCourseCategory) {
    
        let categoryColor = category.color
        
        self.imageShadowView.backgroundColor = categoryColor
        self.titleLabel.textColor = categoryColor
        self.ratingLabel.textColor = categoryColor
        self.priceLabel.backgroundColor = categoryColor
    }
}
