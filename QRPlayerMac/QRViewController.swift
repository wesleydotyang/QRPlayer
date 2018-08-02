//
//  QRViewController.swift
//  QRPlayerMac
//
//  Created by Wesley Yang on 2017/12/4.
//  Copyright © 2017年 ff. All rights reserved.
//

import Cocoa

class QRViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    var timer : Timer?
    
    var pagesEncoded : [String]!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        timer = Timer.init(timeInterval: 0.35, target: self, selector: #selector(QRViewController.updateQR), userInfo: nil, repeats: true)

        RunLoop.main.add(timer!, forMode: RunLoopMode.modalPanelRunLoopMode)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        timer?.invalidate()
    }
    
    @objc func updateQR() {
        let generator = QRCodeGenerator()
        let image:QRImage = generator.createImage(value: (self.pagesEncoded[counter]), size: self.imageView.frame.size)!
        counter += 1
        if counter >= self.pagesEncoded.count {
            counter = 0
        }
        self.imageView.image = image
    }


}
