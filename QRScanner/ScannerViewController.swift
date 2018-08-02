//
//  ViewController.swift
//  QRPlayer
//
//  Created by Wesley Yang on 2017/10/26.
//  Copyright © 2017年 ff. All rights reserved.
//

import UIKit
import AVFoundation
import FileBrowser

class ScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var scanedPages = [UInt16 : QRPageData]()
    var totalPages : UInt16 = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCapture()

        self.view.bringSubview(toFront: textView)
        
    }
    

    func setupCapture()
    {
        let captureDevice_ = AVCaptureDevice.default(for: AVMediaType.video)
        guard let captureDevice = captureDevice_ else{
            return;
        }
        
        let input = try! AVCaptureDeviceInput.init(device: captureDevice)
        captureSession = AVCaptureSession()
        captureSession.addInput(input)
        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScan()
    }
    
    func startScan() {
        captureSession.startRunning()
    }
    
    func stopScan(){
        captureSession.stopRunning()
    }
    
    func completeScan() {
        stopScan()
        
        var allData = Data()
        let meta = QRMetaData.decode(data:(scanedPages[0])!.payload)
        allData.append(meta.payload)
        
        for i in 1 ..< totalPages {
            let pageData = scanedPages[i]
            allData.append(pageData!.payload)
        }
        
        print(meta.fileName)
        
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = docPath + "/" + meta.fileName
        let fileURL = URL.init(fileURLWithPath: filePath)
        try? allData.write(to: fileURL)
        
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }

    func onScanNormalQR(qrStr:String){
        print("scaned\(qrStr)")
        stopScan()
        
        if let url = URL.init(string: qrStr) {//this is an url
            
        }
        
        
        
        let allData = qrStr.data(using: .utf8)
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMdd_HH:mm:ss"
        let dateStr = formatter.string(from: Date())
        let fileName = "text_\(dateStr).txt"
        
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = docPath + "/" + fileName
        let fileURL = URL.init(fileURLWithPath: filePath)
        try? allData?.write(to: fileURL)
        
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for data in metadataObjects {
            if let data = data as? AVMetadataMachineReadableCodeObject{
                if let base64Str = data.stringValue {
                    let rawData = Data.init(base64Encoded: base64Str)
                    if let rawData = rawData {
                        let qr = QRPageData.decode(data: rawData)
                        self.totalPages = qr.numOfPackets
                        scanedPages[qr.index] = qr
                        self.textView.text = "Scaned:\(scanedPages.count)/\(totalPages)"
                        if totalPages == scanedPages.count {
                            self.textView.text = "Complete!"
                            self.completeScan()
                        }
                    }else{//this is a standard qr code
                        onScanNormalQR(qrStr: base64Str)
                    }
                }
            
            }
        }
    }
}

