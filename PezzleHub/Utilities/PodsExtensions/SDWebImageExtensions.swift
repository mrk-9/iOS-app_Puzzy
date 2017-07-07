//
//  SDWebImageExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func setImageWithPlaceholder(_ path: String?, completed: SDWebImageCompletionBlock? = nil) {
        
        let placeholderImage = UIImage(named: "placeholder_image")
        
        guard let path = path else {
            
            self.image = nil
            return
        }
        
        guard let imageURL = URL(string: path) else {
            
            self.image = nil
            return
        }
        
        if let completed = completed {
            
            self.sd_setImage(with: imageURL, completed: completed)

        } else {
            
            self.sd_setImage(with: imageURL, placeholderImage: placeholderImage)
        }
    }
}
