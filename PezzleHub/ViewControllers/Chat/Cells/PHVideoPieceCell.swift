//
//  PHVideoPieceCell.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import MediaPlayer

class PHVideoPieceCell: PHOwnerPieceCell {

    @IBOutlet weak var videoPlayerContainerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var videoPlayerView: PHVideoPlayerView!

	@IBOutlet weak var videoPlayerViewLeftConstraint: NSLayoutConstraint!

    var moviePlayer: AVPlayer!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.videoPlayerViewLeftConstraint.constant = 3.5

        let seekbarThumb = UIImage(named: "video_seekbar_thumb")
        seekSlider.setThumbImage(seekbarThumb, for: UIControlState())

        let seekbar = UIImage(named: "video_seekbar")
        let stretchableImage = seekbar?.stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)
        seekSlider.setMinimumTrackImage(stretchableImage, for: UIControlState())
        seekSlider.setMaximumTrackImage(stretchableImage, for: UIControlState())
    }
    
    // MARK: - PHCourseCategoryColoredView
    override func setCategoryColor(_ category: PHCourseCategory) {

        self.bubbleImageView.image = self.bubbleImageView.image!.coloredImage(category.lightColor)
    }
}
