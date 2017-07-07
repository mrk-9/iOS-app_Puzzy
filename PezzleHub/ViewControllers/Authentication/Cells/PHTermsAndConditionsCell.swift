//
//  TermsAndConditionsCell.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

let termsAndConditionsCellIdentifier = "PHTermsAndConditionsCell"

class PHTermsAndConditionsCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    
    var chapterTitle = "" {
        didSet {
            titleLabel.text = chapterTitle
        }
    }
    
    var chapterDescription = "" {
        didSet {
            descriptionLabel.text = chapterDescription
        }
    }
}
