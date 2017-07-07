//
//  PHAppSettingsViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/13/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import VTAcknowledgementsViewController

class PHAppSettingsViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!

    fileprivate let acknowledgementsIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.navigationBarColor = PHBarColor(tint: UIColor(white: 0.22, alpha: 1.0), background: UIColor.white)

        self.setUpVersionInfo()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    fileprivate func setUpVersionInfo() {
        
        self.versionLabel.text = Bundle.appName+" Ver. "+Bundle.applicationVersion + "("+Bundle.bundleVersion+")"
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case self.acknowledgementsIndexPath:
            
            let settingsBundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle")!
            let acknowledgementsPath = settingsBundlePath + "/Acknowledgements.plist"
            let acknowledgementsViewController = VTAcknowledgementsViewController(acknowledgementsPlistPath: acknowledgementsPath)!
            
            acknowledgementsViewController.headerText = "Powered by CocoaPods.org"
            
            self.navigationController!.pushViewController(acknowledgementsViewController, animated: true)
            
        default:
            break
        }
    }
}
