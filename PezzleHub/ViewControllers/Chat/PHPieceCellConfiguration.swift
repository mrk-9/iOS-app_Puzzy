//
//  PHPieceCellConfiguration.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import MediaPlayer
import BlocksKit

protocol PHPieceCellConfiguration: class {
    
    var playingIndexPath: IndexPath? { get }
    func seekValueAtIndexPath(_ indexPath: IndexPath) -> Float
    func playAtIndexPath(_ indexPath: IndexPath, path: String)
    func pauseAtIndexPath(_ indexPath: IndexPath)
    func switchPlayingStateAtIndexPath(_ indexPath: IndexPath, path: String)
    func seekAtIndexPath(_ indexPath: IndexPath, seekValue: Float)
    
    /// extended methods
    func registerCells(_ tableView: UITableView)
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, piece: PHPiece) -> PHPieceCell
}

extension PHPieceCellConfiguration where Self: UIViewController {
    
    func registerCells(_ tableView: UITableView) {
        
        tableView.registerCell(PHPieceCell.self)
        tableView.registerCell(PHTextPieceCell.self)
        tableView.registerCell(PHPicturePieceCell.self)
        tableView.registerCell(PHUserReactionPieceCell.self)
        tableView.registerCell(PHURLPieceCell.self)
        tableView.registerCell(PHAudioPieceCell.self)
        tableView.registerCell(PHVideoPieceCell.self)
        tableView.registerCell(PHEPubPieceCell.self)
        tableView.registerCell(PHPDFPieceCell.self)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath, piece: PHPiece) {
        switch piece {  // [CAUTION] Child classes should be placed AFTER its parent class (e.g. PHAudioPiece comes after PHURLPiece, because parent cases catch children)
        case let videoPiece as PHVideoPiece:
            self.tableView(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath, videoPiece: videoPiece)

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath, videoPiece: PHVideoPiece) {

        let cell = cell as! PHVideoPieceCell

        cell.moviePlayer.pause()
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, piece: PHPiece) -> PHPieceCell {
        
        switch piece {  // [CAUTION] Child classes should be placed AFTER its parent class (e.g. PHAudioPiece comes after PHURLPiece, because parent cases catch children)
            //        case let userPlayPiece as PHUserPlayPiece:  // FixMe:
            //            break
            
        case let userReactionPiece as PHUserReactionPiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, userReactionPiece: userReactionPiece)
            
        case let picturePiece as PHPicturePiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, picturePiece: picturePiece)
            
            //        case let ownerPiece as PHOwnerTextPiece:  // FixMe:
            //            break
            
        case let articlePiece as PHArticlePiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, URLPiece: articlePiece)  // FixMe:
            
        case let audioPiece as PHAudioPiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, audioPiece: audioPiece)
            
        case let videoPiece as PHVideoPiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, videoPiece: videoPiece)

        case let ePubPiece as PHEPubPiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, ePubPiece: ePubPiece)

        case let PDFPiece as PHPDFPiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, PDFPiece: PDFPiece)

        case let URLPiece as PHURLPiece:
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, URLPiece: URLPiece)
            
        default:    // TODO: Create concrete PieceCell classes and remove default statement
            return self.tableView(tableView, cellForRowAtIndexPath: indexPath, textPiece: piece)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, textPiece: PHPiece) -> PHTextPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHTextPieceCell.self, indexPath: indexPath)
        
        cell.messageLabel.text = textPiece.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, userReactionPiece: PHUserReactionPiece) -> PHUserReactionPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHUserReactionPieceCell.self, indexPath: indexPath)
        
        cell.messageLabel.text = userReactionPiece.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, URLPiece: PHURLPiece) -> PHURLPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHURLPieceCell.self, indexPath: indexPath)
        
//        let attributes: [String: AnyObject] = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue ]
//        let underlinedTitle = NSAttributedString(string: URLPiece.title, attributes: attributes)

        cell.messageLabel.text = URLPiece.title
//        cell.messageLabel.attributedText = underlinedTitle

        if let imagePath = URLPiece.imagePath {

            cell.webImageView.setImageWithPlaceholder(imagePath)
//            cell.webImageViewHeightConstraint.constant = tableView.frame.size.height    // This constraints

        } else {

            cell.webImageView.image = nil
//            cell.webImageViewHeightConstraint.constant = 0
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizer { (recognizer, state, location) in
            
            self.presentWebViewController(nil, path: URLPiece.URL, animated: true, completion: nil)
        } as! UITapGestureRecognizer
        
        cell.pieceContentView.removeGestureRecognizers()
        cell.pieceContentView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, picturePiece: PHPicturePiece) -> PHPicturePieceCell {
        
        let cell = tableView.dequeueReusableCell(PHPicturePieceCell.self, indexPath: indexPath)
        
        cell.pictureView.setImageWithPlaceholder(picturePiece.imagePath)
        
        let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizer { (recognizer, state, location) in
            
            self.presentImageViewController("画像", imagePath: picturePiece.imagePath, animated: true, completion: nil)
            } as! UITapGestureRecognizer
        
        cell.pictureView.removeGestureRecognizers()
        cell.pictureView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, audioPiece: PHAudioPiece) -> PHAudioPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHAudioPieceCell.self, indexPath: indexPath)
        let isPlaying = indexPath == self.playingIndexPath
        let playButtonImage = isPlaying ? "video_stop" : "video_start"
        
        cell.slider.value = self.seekValueAtIndexPath(indexPath)
        cell.playButton.setImage(UIImage(named: playButtonImage), for: UIControlState())
        
        cell.playButton.bk_removeEventHandlers(for: .touchUpInside)
        cell.playButton.bk_addEventHandler({ (sender) in
            
            self.switchPlayingStateAtIndexPath(indexPath, path: audioPiece.URL)
            
        }, for: .touchUpInside)
        
        cell.slider.bk_removeEventHandlers(for: .touchUpInside)
        cell.slider.bk_removeEventHandlers(for: .touchUpOutside)

        cell.slider.bk_addEventHandler({ (sender) in
            
            self.pauseAtIndexPath(indexPath)
            
        }, for: .touchDown)

        cell.slider.bk_addEventHandler({ (sender) in
            
            self.seekAtIndexPath(indexPath, seekValue: cell.slider.value)
            self.playAtIndexPath(indexPath, path: audioPiece.URL)
            
        }, for: .touchUpInside)
        
        cell.slider.bk_addEventHandler({ (sender) in
            
            self.seekAtIndexPath(indexPath, seekValue: cell.slider.value)
            self.playAtIndexPath(indexPath, path: audioPiece.URL)

        }, for: .touchUpOutside)
        
        return cell
    }

    fileprivate func setUpMoviePlayer(_ videoURL: URL, cell: PHVideoPieceCell) -> AVPlayer {

        if let oldPlayer = cell.moviePlayer {
            oldPlayer.bk_removeAllBlockObservers()
        }

        let moviePlayer = AVPlayer(url: videoURL)
        cell.moviePlayer = moviePlayer
        cell.videoPlayerView.player = moviePlayer

        let interval = CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC))
        let queue = DispatchQueue.main
        moviePlayer.addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in

            let duration = moviePlayer.currentItem!.asset.duration
            let durationSec = CMTimeGetSeconds(duration)
            let currentSec = CMTimeGetSeconds(time)

            if durationSec == 0 {

                cell.seekSlider.value = 0

            } else {

                cell.seekSlider.value = Float(currentSec / durationSec)
            }
        }
        
        moviePlayer.bk_addObserver(forKeyPath: "rate", task: nil)
//
//        moviePlayer.bk_addObserver(forKeyPath: "rate") { (obj) in
//
//            if moviePlayer.rate == 0.0 {
//
//                let playButtonImage = UIImage(named: "video_start")
//                cell.playButton.setImage(playButtonImage, for: UIControlState())
//
//            } else {
//
//                let playButtonImage = UIImage(named: "video_stop")
//                cell.playButton.setImage(playButtonImage, for: UIControlState())
//            }
//        }
        
        return moviePlayer
    }

    fileprivate func seekMoviePlayer(_ player: AVPlayer, value: Float) {

        let duration = player.currentItem!.asset.duration
        let durationSec = CMTimeGetSeconds(duration)
        let seekSec = durationSec * Float64(value)
        let seek = CMTimeMakeWithSeconds(seekSec, Int32(NSEC_PER_SEC))
        player.seek(to: seek)
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, videoPiece: PHVideoPiece) -> PHVideoPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHVideoPieceCell.self, indexPath: indexPath)
        
        let videoPath = videoPiece.URL
        
        let videoURL = URL(string: videoPath!)!
        let moviePlayer = setUpMoviePlayer(videoURL, cell: cell)

        cell.playButton.bk_removeEventHandlers(for: .touchUpInside)
        cell.playButton.bk_addEventHandler({ (sender) in
            
            if moviePlayer.rate != 0.0 {

                moviePlayer.pause()
                
            } else {
                
                moviePlayer.play()
            }
            
            }, for: .touchUpInside)
        
        cell.fullScreenButton.bk_removeEventHandlers(for: .touchUpInside)
        cell.fullScreenButton.bk_addEventHandler({ (sender) in
            
            moviePlayer.pause()

            let vc = PHVideoPlayerViewController()
            vc.player = moviePlayer
            cell.videoPlayerView.player = nil

            vc.onDone = {
                moviePlayer.pause()
                vc.player = nil
                cell.videoPlayerView.player = moviePlayer
            }
            
            self.present(vc, animated: true, completion: nil)

            }, for: .touchUpInside)

        cell.seekSlider.bk_removeEventHandlers(for: .valueChanged)
        cell.seekSlider.bk_addEventHandler({ (sender) in

            self.seekMoviePlayer(moviePlayer, value: cell.seekSlider.value)

            }, for: .valueChanged)

        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, ePubPiece: PHEPubPiece) -> PHEPubPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHEPubPieceCell.self, indexPath: indexPath)
        
        cell.messageLabel.text = ePubPiece.title

        let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizer { (recognizer, state, location) in
            
            //            let ePubReaderController = PHEPubReaderController.instantiate()
            //            ePubReaderController.URL = ePubPiece.URL
            //
            //            self.presentViewControllerEmbedInNavigationController(ePubReaderController, animated: true, completion: nil)
            
            let url = URL(string: ePubPiece.URL)!
            UIApplication.shared.openURL(url)

        } as! UITapGestureRecognizer
        
        cell.pieceContentView.removeGestureRecognizers()
        cell.pieceContentView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, PDFPiece: PHPDFPiece) -> PHPDFPieceCell {
        
        let cell = tableView.dequeueReusableCell(PHPDFPieceCell.self, indexPath: indexPath)
        
        cell.messageLabel.text = PDFPiece.title

        let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizer { (recognizer, state, location) in
            
            self.presentWebViewController(nil, path: PDFPiece.URL, animated: true, completion: nil)

        } as! UITapGestureRecognizer
        
        cell.pieceContentView.removeGestureRecognizers()
        cell.pieceContentView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
}
