//
//  PHQRReaderViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/15/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class PHQRReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - Accessor
    fileprivate let supportedBarCodes = [AVMetadataObjectTypeQRCode]

    fileprivate var captureSession: AVCaptureSession?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var guideView: UIView!

    class var isVideoDeviceAvailable: Bool {
        return (AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).isEmpty == false)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupQRCodeReader()

        let colorTheme = getColorTheme()
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.checkQRCodeReader()
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QR Code
    func setupQRCodeReader() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            self.captureSession = AVCaptureSession()
            self.captureSession?.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            self.captureSession?.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = self.supportedBarCodes
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer?.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.previewLayer!)
            
            self.captureSession?.startRunning()
            
            self.guideView = UIView()
            self.guideView.layer.borderColor = UIColor.green.cgColor
            self.guideView.layer.borderWidth = 2
            self.view.addSubview(self.guideView)
            self.view.bringSubview(toFront: self.guideView)
            
        } catch {
        }
    }
    
    func checkQRCodeReader() {
        
        if self.captureSession != nil {
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .denied:
            
            let title = "カメラの使用を許可してください"
            let message = "QRコード読み取りにカメラを使用します。「許可する」を押してカメラの使用を許可してください"
            
            self.presentAlert(title, message: message, okButtonTitle: "許可する", cancelButtonTitle: "閉じる", okHandler: { (action) in
                
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
                
                }, cancelHandler: { (action) in
                    
                    self.dismiss(self)
            })
            
        case .restricted:
            
            let title = "カメラを使用できません"
            let message = "あなたはカメラの使用を許可されていないようです。"
            
            self.presentAlert(title, message: message, okButtonTitle: nil, cancelButtonTitle: "閉じる", cancelHandler: { (action) in
                
                self.dismiss(self)
            })
            
        default:
            break
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        guard metadataObjects != nil && metadataObjects.count > 0 else {
            
            self.guideView.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.supportedBarCodes.contains(metadataObj.type) {
            
            let barCodeObject = self.previewLayer?.transformedMetadataObject(for: metadataObj)
            self.guideView.frame = barCodeObject!.bounds
            
            if let courseID = self.extractCourseID(metadataObj.stringValue) {
                
                self.captureSession?.stopRunning()
                self.guideView.frame = CGRect.zero

                self.showCourseView(courseID)
                
            } else {
                
                self.showNotValidQRCodeAlert()
            }
        }
    }
    
    func showNotValidQRCodeAlert() {
        
        self.presentAlert("QRコードを開けません", message: nil, dismissButtonTitle: "閉じる")
    }
    
    func extractCourseID(_ code: String?) -> Int? {
        
        guard let code = code else {
            return nil
        }
        guard let regex = (try? NSRegularExpression(pattern: perzzleCourseURLPattern, options: .caseInsensitive)) else {
            return nil
        }
        guard let textChekingResult = regex.firstMatch(in: code, options: .anchored, range: code.range) else {
            return nil
        }
        
        let matchRange = textChekingResult.rangeAt(1)
        let matchedString = (code as NSString).substring(with: matchRange)
        
        return Int(matchedString)
    }
    
    // MARK: -
    fileprivate func showCourseView(_ courseID: Int) {
        
        PHAPIManager.defaultManager.requestObject(.GetCourse(isMine: false, courseID: courseID)) {[weak self] (response: Alamofire.DataResponse<PHCourse>) in
            
            guard let course = response.result.value else {
                
                self?.showNotValidQRCodeAlert()
                self?.captureSession?.startRunning()
                return
            }
            
            let courseViewController = PHCourseViewController.instantiate()
            courseViewController.course = course
            courseViewController.isMyCourse = false
            
            courseViewController.navigationItem.hidesBackButton = true
            courseViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: courseViewController, action: #selector(courseViewController.dismiss(_:)))
            
            self?.navigationController!.pushViewController(courseViewController, animated: true)
        }
    }
}
