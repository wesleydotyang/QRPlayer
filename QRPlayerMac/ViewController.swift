//
//  ViewController.swift
//  QRPlayerMac
//
//  Created by Wesley Yang on 2017/10/27.
//  Copyright © 2017年 ff. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,DragDestViewDelegate {
    
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var dragDestView: DragDestView!
    @IBOutlet var textView: NSTextView!
    
    var targetFileURL : URL?
    var pagesEncoded : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragDestView.delegate = self

    }

    func processFileURL(_ url: URL) {
        print(url)
        targetFileURL = url
    }
    
    @IBAction func doButtonTapped(_ sender: Any) {
        
        var pages : [QRPageData]?
        let pageSize = 1500
        
        if let url = targetFileURL {
            pages = QRPageData.encode(file: url, pageSize: pageSize)
        }else{
            let str = textView.textStorage?.string
            if str != nil && str?.isEmpty == false {
                pages = QRPageData.encode(string: str!, pageSize: pageSize)
            }
        }

        if let pages = pages {
            print("total pages:\(pages.count)")
            print(pages.last!)
            
            let encodedPages = pages.map({ (qrpage) -> String in
                return qrpage.encode().base64EncodedString()
            })
            gotoQRPageWith(pages: encodedPages)
        }
    }
    

    func gotoQRPageWith(pages:[String]){
        let vc = storyboard?.instantiateController(withIdentifier:NSStoryboard.SceneIdentifier(rawValue: "qr")) as! QRViewController
        vc.pagesEncoded = pages
        self.presentViewControllerAsModalWindow(vc)
    }


}

