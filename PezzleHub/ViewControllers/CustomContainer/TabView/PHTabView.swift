//
//  PHTabView.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHTabViewDelegate {
    
    func tabView(_ tabView: PHTabView, didSelectIndex index: Int)
}

class PHTabView: UIView {
    
    var delegate: PHTabViewDelegate!
    
    var selectedIndex: Int = 0 {
        didSet {
            
            self.segmentedControl.selectedSegmentIndex = self.selectedIndex
            
            if self.tabItems.count > 0 {
                self.delegate.tabView(self, didSelectIndex: self.selectedIndex)
            }
        }
    }

    fileprivate var tabItems: [PHTabViewItem] = []

    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colorTheme = getColorTheme()
        
        self.backgroundColor = colorTheme.tabBackgroundColor
        self.autoresizingMask = [ .flexibleWidth, .flexibleBottomMargin ]
        
        self.clearTabs()

        // Following code makes segmented control's corner square
//        let selectedBackgroundImage = UIImage(named: "blank4")!.coloredImage(colorTheme.tabSelectedBackgroundColor)
//        let unselectedBackgroundImage = UIImage(named: "blank4")!.coloredImage(colorTheme.tabUnselectedBackgroundColor)
//        
//        self.segmentedControl.setBackgroundImage(selectedBackgroundImage, forState: .Selected, barMetrics: .Default)
//        self.segmentedControl.setBackgroundImage(unselectedBackgroundImage, forState: .Normal, barMetrics: .Default)
        
        let selectedTitleAttributes = [ NSForegroundColorAttributeName: colorTheme.tabSelectedTextColor ]
        let unselectedTitleAttributes = [ NSForegroundColorAttributeName: colorTheme.tabUnselectedTextColor ]
        
        self.segmentedControl.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        self.segmentedControl.setTitleTextAttributes(unselectedTitleAttributes, for: UIControlState())
    }
    
    func setTabs(_ tabItems: [PHTabViewItem], index: Int) {
        
        self.tabItems = tabItems
        self.clearTabs()
        
        for (index, item) in tabItems.enumerated() {
            
            self.segmentedControl.insertSegment(withTitle: item.title, at: index, animated: false)
        }

        self.selectedIndex = tabItems.count > index ? index : 0
    }
    
    fileprivate func clearTabs() {
        
        self.segmentedControl.removeAllSegments()
    }
    
    @objc fileprivate func tabSelected(_ sender: UIButton!) {
        self.selectedIndex = sender.tag
    }
    
    @IBAction func segmentedControlDidChangeValue(_ sender: AnyObject!) {
        
        self.selectedIndex = self.segmentedControl.selectedSegmentIndex
    }
}
