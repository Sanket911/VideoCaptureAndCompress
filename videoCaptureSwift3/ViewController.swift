//
//  ViewController.swift
//  videoCaptureSwift3
//
//  Created by Sanket on 07/05/17

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
        
        @IBOutlet weak var camPreview: UIView!
        
        let cameraButton = UIView()
        
        let captureSession = AVCaptureSession()
        
        let movieOutput = AVCaptureMovieFileOutput()
        
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        var activeInput: AVCaptureDeviceInput!
        
        var outputURL: URL!
        
        override func viewDidLoad() {
                super.viewDidLoad()
        }
        
        override func viewDidAppear(_ animated: Bool) {
                if setupSession() {
                        setupPreview()
                        startSession()
                }
                
                cameraButton.isUserInteractionEnabled = true
                
                let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.startCapture))
                
                cameraButton.addGestureRecognizer(cameraButtonRecognizer)
                
                cameraButton.frame = CGRect(x: camPreview.frame.width/2 - 30, y: camPreview.frame.height-90, width: 60, height: 60)
                
                cameraButton.backgroundColor = UIColor.gray
                
                camPreview.addSubview(cameraButton)
        }
        
        func setupPreview() {
                // Configure previewLayer
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = camPreview.bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                camPreview.layer.addSublayer(previewLayer)
        }
        
        //MARK:- Setup Camera
        
        func setupSession() -> Bool {
                
                captureSession.sessionPreset = AVCaptureSessionPresetHigh
                
                // Setup Camera
                let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                
                do {
                        let input = try AVCaptureDeviceInput(device: camera)
                        if captureSession.canAddInput(input) {
                                captureSession.addInput(input)
                                activeInput = input
                        }
                } catch {
                        print("Error setting device video input: \(error)")
                        return false
                }
                
                // Setup Microphone
                let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
                
                do {
                        let micInput = try AVCaptureDeviceInput(device: microphone)
                        if captureSession.canAddInput(micInput) {
                                captureSession.addInput(micInput)
                        }
                } catch {
                        print("Error setting device audio input: \(error)")
                        return false
                }
                
                
                // Movie output
                if captureSession.canAddOutput(movieOutput) {
                        captureSession.addOutput(movieOutput)
                }
                
                return true
        }
        
        func setupCaptureMode(_ mode: Int) {
                // Video Mode
                
        }
        
        //MARK:- Camera Session
        func startSession() {
                
                
                if !captureSession.isRunning {
                        videoQueue().async {
                                self.captureSession.startRunning()
                        }
                }
        }
        
        func stopSession() {
                if captureSession.isRunning {
                        videoQueue().async {
                                self.captureSession.stopRunning()
                        }
                }
        }
        
        func videoQueue() -> DispatchQueue {
                return DispatchQueue.main
        }
        
        
        
        func currentVideoOrientation() -> AVCaptureVideoOrientation {
                var orientation: AVCaptureVideoOrientation
                
                switch UIDevice.current.orientation {
                case .portrait:
                        orientation = AVCaptureVideoOrientation.portrait
                case .landscapeRight:
                        orientation = AVCaptureVideoOrientation.landscapeLeft
                case .portraitUpsideDown:
                        orientation = AVCaptureVideoOrientation.portraitUpsideDown
                default:
                        orientation = AVCaptureVideoOrientation.landscapeRight
                }
                
                return orientation
        }
        
        func startCapture() {
                
                startRecording()
                
        }
        
        func tempURL() -> URL? {
                let directory = NSTemporaryDirectory() as NSString
                
                if directory != "" {
                        let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
                        return URL(fileURLWithPath: path)
                }
                
                return nil
        }
        
        
        func startRecording() {
                
                if movieOutput.isRecording == false {
                        
                        
                        
                        let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
                        if (connection?.isVideoOrientationSupported)! {
                                connection?.videoOrientation = currentVideoOrientation()
                        }
                        
                        if (connection?.isVideoStabilizationSupported)! {
                                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                        }
                        
                        let device = activeInput.device
                        if (device?.isSmoothAutoFocusSupported)! {
                                do {
                                        try device?.lockForConfiguration()
                                        device?.isSmoothAutoFocusEnabled = false
                                        device?.unlockForConfiguration()
                                } catch {
                                        print("Error setting configuration: \(error)")
                                }
                                
                        }
                        
                        //EDIT2: And I forgot this
                        outputURL = tempURL()
                        movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
                        
                        cameraButton.backgroundColor = UIColor.red
                        
                }
                else {
                        stopRecording()
                }
                
        }
        
        func stopRecording() {
                
                if movieOutput.isRecording == true {
                        movieOutput.stopRecording()
                        cameraButton.backgroundColor = UIColor.gray
                }
        }
        
        func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
                
        }
        
        func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
                if (error != nil) {
                        print("Error recording movie: \(error!.localizedDescription)")
                } else {
                        
                        //                        _ = outputURL as URL
//                        let videoRecorded = outputURL! as URL
                        
                        // performSegue(withIdentifier: "showVideo", sender: videoRecorded)
                        guard let data = NSData(contentsOf: outputFileURL as URL) else {
                                return
                        }
                        
                        print("File size before compression: \(Double(data.length / 1048576)) mb")
                        
                        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                        compressVideo(inputURL: outputFileURL as URL, outputURL: compressedURL) { (exportSession) in
                                guard let session = exportSession else {
                                        return
                                }
                                
                                switch session.status {
                                case .unknown:
                                        break
                                case .waiting:
                                        break
                                case .exporting:
                                        break
                                case .completed:
                                        guard let compressedData = NSData(contentsOf: compressedURL) else {
                                                return
                                        }
                                        
//                                        let afterCompress:Double = Double(compressedData.length / 1048576)
                                        
                                        
                                        print("File size after compression: \(Double(compressedData.length / 1024)) kb")
                                        
                                        
//                                        let dicSet : NSMutableDictionary!
                                        var dicSet = [String : Any]()
                                        dicSet["URL"] = compressedURL
                                        dicSet["before"] = "File size before compression: \(Double(data.length / 1048576)) mb";
                                        dicSet["after"] = "File size after compression: \(Double(compressedData.length / 1024)) kb";
                                        
                                        self.performSegue(withIdentifier: "showVideo", sender: dicSet)
                                        
                                case .failed:
                                        break
                                case .cancelled:
                                        break
                                }
                        }
                        
                }
                outputURL = nil
        }
        
        func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
                let urlAsset = AVURLAsset(url: inputURL, options: nil)
                guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
                        handler(nil)
                        
                        return
                }
                
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileTypeQuickTimeMovie
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.exportAsynchronously { () -> Void in
                        handler(exportSession)
                }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
                let vc = segue.destination as! VideoPlaybackViewController
                
                let dict = sender as! [String : Any]
                
//                vc.videoURL = dict.value(forKey: "URL") as! URL!;
//                vc.beforeCompression = dict.value(forKey: "before") as! String!;
//                vc.afterCompression = dict.value(forKey: "after") as! String!
                
                vc.videoURL = dict["URL"] as! URL!;
                vc.beforeCompression = dict["before"] as! String!;
                vc.afterCompression = dict["after"] as! String!;
                
        }
}

