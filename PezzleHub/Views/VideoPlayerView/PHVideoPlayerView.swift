//
//  PHVideoPlayerView.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import AVFoundation

class PHVideoPlayerView: UIView {

    var player: AVPlayer! {
        get {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            return layer.player
        }
        set(newValue) {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            layer.player = newValue
        }
    }

    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    func setVideoFillMode(_ mode: String) {
        let layer = self.layer as! AVPlayerLayer
        layer.videoGravity = mode
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let corners: UIRectCorner = [.topLeft, .topRight]
        let radii = CGSize(width: 20, height: 20)
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)

        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath

        self.layer.mask = maskLayer
    }

}
