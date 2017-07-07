//
//  CourseRoomVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/12/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import AVFoundation
import GVUserDefaults
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol PHChatViewControllerDelegate {
    
    func chatViewController(_ controller: PHChatViewController, didFinishChapter chapter: PHChapter)
    func chatViewController(_ controller: PHChatViewController, didChangeProgress progress: Float)
}

extension PHChatViewControllerDelegate {
    
    func chatViewController(_ controller: PHChatViewController, didFinishChapter chapter: PHChapter) {}
    func chatViewController(_ controller: PHChatViewController, didChangeProgress progress: Float) {}
}

protocol PHChatViewControllerExtensions: class, PHActivityIndicatorController {
    
    func didFinishChapter()
}

class PHChatOverlayView: UIView {
    
    @IBOutlet weak var chapterTitleLabel: UILabel!
    @IBOutlet weak var chapterNumberLabel: UILabel!
    @IBOutlet weak var startChapterLabel: UILabel!
    @IBOutlet weak var chapterPlayButton: UIButton!
}

class PHChatViewController: UIViewController, PHPieceCellConfiguration, PHChatViewControllerExtensions {
    
    enum ChapterState: Int {
        case notStarted
        case playing
        case finished
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var overlayView: PHChatOverlayView!
    @IBOutlet weak var userInputView: PHChatUserInputView!
    
    var delegate: PHChatViewControllerDelegate?
    
    var isMyPieces = false
    var course: PHCourse!
    var chapter: PHChapter!

    fileprivate var loadedPieceList: [PHPiece] = []
    fileprivate var displayingPieceList: [PHPiece] = []
    fileprivate let shownCellIndexSet = NSMutableIndexSet()

    fileprivate var nextPieceIndex = 0 {
        didSet {
            
            guard self.loadedPieceList.count > 0 else {
                
                self.delegate?.chatViewController(self, didChangeProgress: 0.0)
                return
            }
            
            let progress = Float(self.nextPieceIndex) / Float(self.loadedPieceList.count)
            
            self.delegate?.chatViewController(self, didChangeProgress: progress > 1.0 ? 1.0 : progress)
        }
    }
    
    fileprivate var pieceAppearanceInterval: TimeInterval = 1.6

    fileprivate var previousContentOffsetY: CGFloat = 0.0
    
    fileprivate var currentChapterState = ChapterState.notStarted {
        didSet {
            
//            if self.currentChapterState == oldValue { // To initialize by setting a same value (in viewDidLoad self.currentChapterState = .NotStarted)
//                return
//            }
            
            switch self.currentChapterState {
            case .notStarted:
                self.userInputView.playButtonHidden(true, animated: false)
                self.userInputView.completeButtonHidden(true, animated: false)
                
            case .playing:
                self.userInputView.completeButtonHidden(true, animated: false)
                
            case .finished:
                
                
                self.shownCellIndexSet.removeAllIndexes()
                
                self.viewAllButtonHidden(true, animated: false)
                self.userInputView.playButtonHidden(true, animated: false)
                self.userInputView.completeButtonHidden(false, animated: false)
                
                if self.course.lastCompletedChapterNumber < Int(self.chapter.number)! {
                    self.userInputView.completeButtonEnable(true)
                } else {
                    self.userInputView.completeButtonEnable(false)

                }

            }
        }
    }

    fileprivate var cellHeightCache: [Int:CGFloat] = [:]
    fileprivate var autoScrollLink: CADisplayLink?
    fileprivate var autoScrollSpeed: CGFloat = 0

    /// audio
    fileprivate var audioSeek: Float = 0.0
    fileprivate var mediaPlayer: AVPlayer?
    var playingIndexPath: IndexPath?
    var seekValueAtIndex: [Int: Float] = [:]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerCells(self.tableView)
        
        self.tableView.contentInset.bottom += 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.setUpOverlayView()

        let userDefaults = GVUserDefaults.standard()
        self.pieceAppearanceInterval = TimeInterval((userDefaults?.displaySpeed)!)

        self.loadData()
        
        self.currentChapterState = .notStarted
    }
    
    fileprivate func setUpOverlayView() {
        
        self.overlayView.chapterNumberLabel.text = "第"+self.chapter.number+"回"
        self.overlayView.chapterTitleLabel.text = self.chapter.title
    }

    // MARL: - Data
    fileprivate func loadData() {

        PHAPIManager.defaultManager.requestJSON(.GetPieces(isMine: self.isMyPieces, chapterID: self.chapter.id)) {[weak self] (response) in
            
            if let JSONData = response.result.value as? [[String: AnyObject]] {
             
                var pieces: [PHPiece] = []
                
                for aJSON in JSONData {
                    
                    let type = aJSON["type"] as! String
                    let object = PHPiece.map(type, JSONDictionary: aJSON)
                    pieces.append(object)
                }
                
                self?.loadedPieceList = pieces
                self?.displayingPieceList = []
                
                self?.overlayView.chapterPlayButton.isHidden = false
                
                if let chapterID = self?.chapter.id {
                 
                    if let readIndexNumber = GVUserDefaults.standard().asReadPieceID(inChapter: chapterID) {
                        
                        self?.overlayView.isHidden = true
                        self?.showPiecesUntilPieceID(readIndexNumber.intValue)
                        
                    }
                }
            }
        }
    }
    
    fileprivate func showNextPiece(_ delay: TimeInterval) {
        
        self.currentChapterState = .playing
        
        guard self.nextPieceIndex < self.loadedPieceList.count else {
            
            performAfterDelay(delay, block: { 
                self.currentChapterState = .finished
            })
            return
        }
        
        performAfterDelay(delay) {
        
            guard self.nextPieceIndex < self.loadedPieceList.count else {
                return  // In case self.nextPieceIndex was changed (e.g. viewAllPieces()) while waiting the delay.
            }
            let nextPiece = self.loadedPieceList[self.nextPieceIndex]

            GVUserDefaults.standard().setChapterAsReadPiece(self.chapter.id, pieceID: nextPiece.id)
            
            if let userPiece = nextPiece as? PHUserPiece {
                
                self.reloadUserPiece(userPiece)
                return
            }

            self.displayingPieceList.append(nextPiece)
            self.nextPieceIndex += 1
            
            self.tableView.reloadData()
            self.startAutoScroll()

            self.showNextPiece(self.pieceAppearanceInterval)
        }
    }
    
    fileprivate func reloadUserPiece(_ piece: PHUserPiece) {

        self.userInputView.playButtonHidden(false, animated: true)
                
        performAfterDelay(1.0) { 
            self.userInputView.startHeartbeat()
        }

        if piece is PHUserReactionPiece {

            self.userInputView.playButtonAppearance = .bubble
            
        } else {

            self.userInputView.playButtonAppearance = .normal
        }
    }
    
    fileprivate func reloadData() {
        
        self.tableView.reloadData()
    }
    
    // MARK: - Action
    @IBAction func userPlay(_ sender: AnyObject!) {
        
        let userDefaults = GVUserDefaults.standard()
        self.pieceAppearanceInterval = TimeInterval((userDefaults?.displaySpeed)!)

        self.play()
    }
    
    @IBAction func completeChapter(_ sender: AnyObject!) {

        self.didFinishChapter()
        self.delegate?.chatViewController(self, didFinishChapter: self.chapter)
    }
    
    func showPiecesUntilPieceID(_ pieceID: Int) {
        
        let index = self.loadedPieceList.index { $0.id == pieceID } as Int? ?? 0
        
        self.showPiecesUntilIndex(index)
    }
    
    func showPiecesUntilIndex(_ index: Int) {
        
        self.nextPieceIndex = index
        self.stopAutoScroll()
        
        if self.nextPieceIndex >= self.loadedPieceList.count {

            self.currentChapterState = .finished

        } else {
            
            self.currentChapterState = .playing
        }
        
        let count = self.loadedPieceList.count < self.nextPieceIndex ? self.loadedPieceList.count : self.nextPieceIndex
        
        self.displayingPieceList = self.loadedPieceList[0..<count].filter { $0.shouldDisplayInHistory }
        self.shownCellIndexSet.removeAllIndexes()
        self.shownCellIndexSet.add(in: NSRange(location: 0, length: self.nextPieceIndex))
        self.tableView.reloadData()
        
        self.showNextPiece(self.pieceAppearanceInterval / 2.0)
    }

    @IBAction func viewAllPieces(_ sender: AnyObject!) {
        
        self.showPiecesUntilIndex(Int.max)
        
        self.viewAllButtonHidden(true, animated: true)
    }

    fileprivate func viewAllButtonHidden(_ hidden: Bool, animated: Bool) {
        // Only this method should call self.userInputView.viewAllButtonHidden()
        
        guard self.currentChapterState == .playing else {
            
            self.userInputView.viewAllButtonHidden(true, animated: animated)
            return
        }
        
        let chapterNumber = Int(self.chapter.number)
        
        guard chapterNumber <= self.course.lastCompletedChapterNumber else {
            
            self.userInputView.viewAllButtonHidden(true, animated: animated)
            return
        }

        guard self.nextPieceIndex < self.loadedPieceList.count else {
            
            self.userInputView.viewAllButtonHidden(true, animated: animated)
            return
        }
        
        self.userInputView.viewAllButtonHidden(hidden, animated: animated)
    }
    
    @IBAction func userOverlayPlay(_ sender: AnyObject!) {
        
        self.overlayView.isHidden = true
        self.play()
    }

    fileprivate func play() {
        
        guard self.loadedPieceList.isEmpty == false else {
            return
        }
        
        self.viewAllButtonHidden(false, animated: true)
        self.userInputView.playButtonHidden(true, animated: true)
        
        self.userInputView.stopHeartbeat()

        let nextPiece = self.loadedPieceList[self.nextPieceIndex]
        var delay = 0.1
        
        if nextPiece.shouldDisplayInHistory {
            
            delay = self.pieceAppearanceInterval
            
            self.displayingPieceList.append(nextPiece)

            self.tableView.reloadData()
            self.startAutoScroll()
        }
        
        self.nextPieceIndex += 1
        
        self.showNextPiece(delay)
    }
    /*
    private func replay() {
        
        self.displayingPieceList = []
        self.tableView.reloadData()
        
        self.nextPieceIndex = 0
        self.showNextPiece(self.pieceAppearanceInterval / 2.0)
        
        self.currentChapterState = .Playing
    }
 */

    // MARK: - Audio
    func seekValueAtIndexPath(_ indexPath: IndexPath) -> Float {
        
        if self.seekValueAtIndex[(indexPath as NSIndexPath).row] == nil {
            self.seekValueAtIndex[(indexPath as NSIndexPath).row] = 0.0
        }
        
        return self.seekValueAtIndex[(indexPath as NSIndexPath).row]!
    }
    
    func playAtIndexPath(_ indexPath: IndexPath, path: String) {
        
        guard let mediaURL = URL(string: path) else {
            return
        }

        var canUseCurrentPlayer = false
        
        if let asset = self.mediaPlayer?.currentItem as AnyObject? as? AVURLAsset {
            
            if asset.url == mediaURL {
                
                canUseCurrentPlayer = true
            }
        }
        
        if canUseCurrentPlayer {
            
            self.mediaPlayer!.play()
            
        } else {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.mediaPlayer?.currentItem)
            self.mediaPlayer = nil
            
            self.mediaPlayer = AVPlayer(url: mediaURL)
            let seekValue = self.seekValueAtIndexPath(indexPath)
            
            let duration = self.mediaPlayer!.currentItem!.asset.duration
            let durationSec = CMTimeGetSeconds(duration)
            let seekSec = durationSec * Float64(seekValue)
            let seek = CMTimeMakeWithSeconds(seekSec, Int32(NSEC_PER_SEC))
            
            let interval = CMTimeMake(200, 600)
            self.mediaPlayer!.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (time) in
                
                let currentSecond = CMTimeGetSeconds(time)
                let duration = CMTimeGetSeconds(self.mediaPlayer!.currentItem!.asset.duration)
                
                let seekValue = Float(currentSecond / duration)
                self.seekValueAtIndex[(indexPath as NSIndexPath).row] = seekValue
                
                DispatchQueue.main.async(execute: {
                    
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                })
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.mediaPlayerDidFinishPlaying(_:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.mediaPlayer!.currentItem)
            
            self.mediaPlayer!.seek(to: seek)
            self.mediaPlayer!.play()
        }
        
        self.playingIndexPath = indexPath
    }
    
    func pauseAtIndexPath(_ indexPath: IndexPath) {
        
        self.mediaPlayer?.pause()
        self.playingIndexPath = nil
    }

    func switchPlayingStateAtIndexPath(_ indexPath: IndexPath, path: String) {
        
        guard let _ = URL(string: path) else {
            return
        }
        
        let previousIndexPath = self.playingIndexPath
        let isPlaying = indexPath == previousIndexPath
        
        if isPlaying {
            
            self.pauseAtIndexPath(indexPath)
            
        } else {
            
            self.playAtIndexPath(indexPath, path: path)
        }
        
        if let previousIndexPath = previousIndexPath {
            self.tableView.reloadRows(at: [previousIndexPath], with: UITableViewRowAnimation.none)
        }
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }

    func seekAtIndexPath(_ indexPath: IndexPath, seekValue: Float) {
        
        guard let duration = self.mediaPlayer?.currentItem?.asset.duration else {
            return
        }
        
        let durationSec = CMTimeGetSeconds(duration)
        let seekSec = durationSec * Float64(seekValue)
        let seek = CMTimeMakeWithSeconds(seekSec, Int32(NSEC_PER_SEC))

        self.mediaPlayer!.seek(to: seek)
    }
    
    func mediaPlayerDidFinishPlaying(_ notification: Notification!) {
        
        let indexPath = self.playingIndexPath!
        self.playingIndexPath = nil
        
        self.seekValueAtIndex[(indexPath as NSIndexPath).row] = 0.0
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
}

// MARK: - UITableViewDataSource
extension PHChatViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayingPieceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let piece = self.displayingPieceList[(indexPath as NSIndexPath).row]
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath, piece: piece)
        
        cell.setCategoryColor(self.course.category)
        
        if self.shownCellIndexSet.contains((indexPath as NSIndexPath).row) == false {
            self.shownCellIndexSet.add((indexPath as NSIndexPath).row)
            cell.runAnimation(self.course.imagePath)
        }
        return cell
    }

    @objc(tableView:didEndDisplayingCell:forRowAtIndexPath:) func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if (indexPath as NSIndexPath).row > 0 && self.displayingPieceList.count > 0 {
            let piece = self.displayingPieceList[(indexPath as NSIndexPath).row]
            self.tableView(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath, piece: piece)
        }
    }
}

// MARK: - UITableViewDelegate
extension PHChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let height = self.cellHeightCache[(indexPath as NSIndexPath).row] {
            return height
        }

        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if let height = self.cellHeightCache[(indexPath as NSIndexPath).row] {
            return height
        }

        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightCache[(indexPath as NSIndexPath).row] = cell.bounds.height
    }
}

// MARK: - AutoScroll
extension PHChatViewController {
    
    fileprivate func startAutoScroll() {
        
        if self.autoScrollLink == nil {
            let link = CADisplayLink(target: self, selector: #selector(PHChatViewController.momentumScroll(_:)))
            link.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            self.autoScrollLink = link
        } else {
            self.autoScrollSpeed = 0
        }
    }
    
    func momentumScroll(_ link: CADisplayLink) {
        
        let bottom = self.tableView.contentSize.height - self.tableView.frame.size.height + self.tableView.contentInset.bottom
        
        if self.autoScrollSpeed == 0 {

            let interval = CGFloat(self.pieceAppearanceInterval)
            self.autoScrollSpeed = (bottom - self.tableView.contentOffset.y) / interval
        }
        
        if self.tableView.contentOffset.y >= bottom {
            
            self.stopAutoScroll()
            
        } else {
            
            self.tableView.contentOffset.y += self.autoScrollSpeed * CGFloat(link.duration)
        }
    }
    
    fileprivate func stopAutoScroll() {
        
        self.autoScrollLink?.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.autoScrollLink = nil
        self.autoScrollSpeed = 0
    }
}

extension PHChatViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.tableView === scrollView {
            
            let y = scrollView.contentOffset.y
            let diff = y - self.previousContentOffsetY
            var viewAllButtonHidden = diff < 0.0
            
            if y > (scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom - 10.0) {
                
                viewAllButtonHidden = false
                
            } else if y <= scrollView.contentInset.top + 10.0 {
                
                viewAllButtonHidden = true
            }
            
            self.viewAllButtonHidden(viewAllButtonHidden, animated: true)
            self.previousContentOffsetY = scrollView.contentOffset.y
        }
    }
}
