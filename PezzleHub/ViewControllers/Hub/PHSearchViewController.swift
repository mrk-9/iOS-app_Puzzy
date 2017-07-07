//
//  PHSearchViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHSearchViewController: UIViewController {
    
    enum SegueIdentifiers: String {
        case CourseListView = "CourseListViewSegue"
    }
    
    fileprivate var searchBar: UISearchBar!
    fileprivate var isFirstLoad = true
    
    @IBOutlet fileprivate weak var emptyView: UIView!
    @IBOutlet fileprivate weak var emptyLabel: UILabel!
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet fileprivate weak var contentViewBottomConstraint: NSLayoutConstraint!
    fileprivate var courseListViewController: PHCourseListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        self.view.backgroundColor = colorTheme.defaultBackgroundColor
        
        self.navigationItem.navigationBarHidden = false
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
        
        self.setUpSearchBar()
        self.setUpGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpKeyboardNotifications()
        
        if self.isFirstLoad {
            self.searchBar.becomeFirstResponder()
            self.isFirstLoad = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tearDownKeyboardNotifications()
        
        self.searchBar.resignFirstResponder()
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpSearchBar() {
        
        self.searchBar = UISearchBar(frame: self.navigationController!.navigationBar.bounds)
        
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search"
        self.searchBar.showsCancelButton = true
        self.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        self.searchBar.keyboardType = UIKeyboardType.default
        self.searchBar.showsCancelButton = false
        
        self.navigationItem.titleView = self.searchBar
    }
    
    fileprivate func setUpGestureRecognizer() {
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self.searchBar, action: #selector(self.searchBar.resignFirstResponder))
        
        panGestureRecognizer.delegate = self
        self.contentView.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - UI
    fileprivate func updateContentViewAppearance(_ shouldShowEmptyView: Bool) {
        
        if shouldShowEmptyView {
            
            if let searchText = self.searchBar.text {
                
                self.emptyLabel.text = "「"+searchText+"」は見つかりませんでした"
                
            } else {
                
                self.emptyLabel.text = ""
            }
            
            self.emptyView.isHidden = false
            self.contentView.isHidden = true
            
        } else {
            
            self.emptyView.isHidden = true
            self.contentView.isHidden = false
        }
    }
    
    // MARK: - UIStoryboardSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch SegueIdentifiers(rawValue: segue.identifier!)! {
        case .CourseListView:
            
            self.courseListViewController = segue.destination as! PHCourseListController
            
            self.courseListViewController.delegate = self
            self.courseListViewController.courseListRouter = PHRouter.GetCourses(isMine: false, parameters: nil)
        }
    }
    
    //MARK: - Keyboard notification observer methods
    override func keyboardRectDidChange(_ rect: CGRect, animationDuration: TimeInterval) {
        
        self.contentViewBottomConstraint.constant = rect.size.height
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
}

extension PHSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            
            self.courseListViewController.courseListRouter = PHRouter.GetCourses(isMine: false, parameters: [ "inname": searchText as AnyObject ])
            
        } else {
            
            self.courseListViewController.courseListRouter = PHRouter.GetCourses(isMine: false, parameters: nil)
        }
    }
}

extension PHSearchViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PHSearchViewController: PHCourseListControllerDelegate {
    
    func courseListController(_ controller: PHCourseListAbstractController, didLoadCourses courses: [PHCourse]?) {
        
        var shouldShowEmptyView = true
        
        if let courses = courses {
            if courses.isEmpty == false {
                shouldShowEmptyView = false
            }
        }
        
        self.updateContentViewAppearance(shouldShowEmptyView)
    }
}
