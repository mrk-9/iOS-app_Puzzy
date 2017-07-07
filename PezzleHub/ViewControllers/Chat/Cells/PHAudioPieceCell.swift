//
//  PHAudioPieceCell.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHAudioPieceCell: PHOwnerPieceCell {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let seekbarThumb = UIImage(named: "video_seekbar_thumb")
        slider.setThumbImage(seekbarThumb, for: UIControlState())

        let seekbar = UIImage(named: "video_seekbar")
        let stretchableImage = seekbar?.stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)
        slider.setMinimumTrackImage(stretchableImage, for: UIControlState())
        slider.setMaximumTrackImage(stretchableImage, for: UIControlState())
    }
    
    // MARK: - PHCourseCategoryColoredView
    override func setCategoryColor(_ category: PHCourseCategory) {

        self.bubbleImageView.image = self.bubbleImageView.image!.coloredImage(category.lightColor)
    }
}
