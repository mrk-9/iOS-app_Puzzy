//
//  TermsAndConditionsCell.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHOwnerCell: UITableViewCell {
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet fileprivate weak var ownerNameLabel: UILabel!
    @IBOutlet fileprivate weak var ownerDescriptionLabel: UILabel!
    
    var ownerName = "" {
        didSet {
            ownerNameLabel.text = ownerName
        }
    }
    
    var ownerDescription = "" {
        didSet {
            ownerDescriptionLabel.text = ownerDescription
        }
    }
}
