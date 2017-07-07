//
//  TermsAndConditionsVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

let fakeTerms = [TermsAndConditionsChapter(), TermsAndConditionsChapter(), TermsAndConditionsChapter(), TermsAndConditionsChapter(), TermsAndConditionsChapter()]

class PHTermsAndConditionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.defaultBackgroundColor

        self.setUpNavigationTitleView(nil, trailingText: "")
        
        let tableHeaderView = PHTermsAndConditionsHeaderView()
        tableHeaderView.chapterClick = {(index) in
            var sectionRect = self.tableView.rect(forSection: index)
            sectionRect.size.height = self.tableView.frame.size.height
            self.tableView.scrollRectToVisible(sectionRect, animated: true)
        }
        tableHeaderView.frame.size.width = self.view.frame.width
        tableHeaderView.chapters = fakeTerms
        self.tableView.tableHeaderView = tableHeaderView
        self.tableView.register(UINib(nibName: termsAndConditionsCellIdentifier, bundle: nil), forCellReuseIdentifier: termsAndConditionsCellIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Action
    @IBAction func back () {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return fakeTerms.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let chapter = fakeTerms[section]
        return chapter.subchapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: termsAndConditionsCellIdentifier) as? PHTermsAndConditionsCell {
            let chapter = fakeTerms[(indexPath as NSIndexPath).section].subchapters[(indexPath as NSIndexPath).row]
            cell.chapterTitle = chapter.title
            cell.chapterDescription = chapter.description
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let chapterView = PHChapterView()
        chapterView.frame.size.width = tableView.frame.width
        let chapter = fakeTerms[section]
        chapterView.numberLabel.text = "第"+String(section+1)+"章"
        chapterView.titleLabel.text = chapter.title
        chapterView.backgroundColor = getColorTheme().defaultBackgroundColor
        return chapterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
