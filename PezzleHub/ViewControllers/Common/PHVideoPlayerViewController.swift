//
//  PHVideoPlayerViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 1/5/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import AVKit

class PHVideoPlayerViewController: AVPlayerViewController {

    var onDone: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.onDone?()
    }

}
