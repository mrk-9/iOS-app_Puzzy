//
//  PHImagePieceCell.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHPicturePieceCell: PHOwnerPieceCell {

    @IBOutlet weak var pictureView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pictureView.layer.borderColor = UIColor.white.cgColor
    }
}
