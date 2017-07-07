//
//  File.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHTermsAndConditionsHeaderView: UIView {
    
    @IBOutlet fileprivate weak var chaptersView: UIView!
    var chapterClick: ((_ index: Int) -> Void)?
    
    var chapters: [TermsAndConditionsChapter] = [] {
        didSet {
            let subviews = chaptersView.subviews
            for subview in subviews {
                subview.removeFromSuperview()
            }
            var chaptersHeight = CGFloat(0)
            for (index, chapter) in chapters.enumerated() {
                let chapterView = PHTermsAndConditionsHeaderChapterView()
                chapterView.frame.size.width = chaptersView.frame.width
                chapterView.frame.origin.y = chaptersHeight
                chapterView.frame.origin.x = 0
                chapterView.chapterIndex = index+1
                chapterView.chapterTitle = chapter.title
                chapterView.titleButton.tag = index
                chapterView.titleButton.addTarget(self, action: #selector(PHTermsAndConditionsHeaderView.chapterClick(_:)), for: .touchUpInside)
                chaptersHeight += chapterView.frame.height
                chaptersView.addSubview(chapterView)
            }
            self.frame.size.height = chaptersView.frame.origin.y + chaptersHeight + 16
        }
    }
    
    func chapterClick(_ chapterButton: UIButton) {
        chapterClick?(chapterButton.tag)
    }
    
    fileprivate func customInit() {
        let view = Bundle.main.loadNibNamed("PHTermsAndConditionsHeaderView", owner: self, options: nil)?.first as! UIView
        self.bounds = view.bounds
        self.addSubview(view)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init () {
        super.init(frame: CGRect.zero)
        self.customInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    
}
