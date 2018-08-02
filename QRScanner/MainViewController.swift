//
//  FileListViewController.swift
//  QRPlayer
//
//  Created by Wesley Yang on 2017/11/17.
//  Copyright © 2017年 ff. All rights reserved.
//

import UIKit
import Foundation
import FileBrowser

class MainViewController: UIViewController {
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var viewFileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanButton.layer.cornerRadius = 210/2;
        viewFileButton.layer.cornerRadius = 4;
        viewFileButton.layer.borderColor = UIColor.blue.cgColor;
        viewFileButton.layer.borderWidth = 1;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
     
    }
    
   
    @IBAction func doViewFileTapped(_ sender: Any) {
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }
    
    
    
}
