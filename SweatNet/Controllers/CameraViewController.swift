//
//  CameraController.swift
//  SweatNet
//
//  Created by Alex on 3/14/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import AVFoundation
import UIKit

var captureSession: AVCaptureSession?
var videoPreviewLayer: AVCaptureVideoPreviewLayer?

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var footageURL: URL?
    //private var animator: UIViewPropertyAnimator?
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: view)
    private var rotate: UIDynamicItemBehavior?
    private var rotate2: UIDynamicItemBehavior?

    @IBOutlet weak var recordingSpinnerInner: UIImageView!
    @IBOutlet weak var recordingSpinner: UIImageView!
    @IBOutlet weak var importMediaButton: UIButton!
    @IBOutlet weak var camPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordingSpinner.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.recordingSpinner.addGestureRecognizer(tap)
        if setupSession(){
            setupPreview()
            startSession()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    
    @objc func handleTap(_ gesture:UITapGestureRecognizer) {
//        if animator == nil {
//            createAnimation()
//        }
        startRecording()
        
        if let rotate = rotate, let rotate2 = rotate2 {
            animator.removeBehavior(rotate)
            animator.removeBehavior(rotate2)
            self.rotate = nil
            self.rotate2 = nil
        } else {
            rotate = UIDynamicItemBehavior(items: [self.recordingSpinner])
            rotate2 = UIDynamicItemBehavior(items: [self.recordingSpinnerInner])
            rotate?.allowsRotation = true
            rotate2?.allowsRotation = true
            rotate?.angularResistance = 0
            rotate2?.angularResistance = 0
            rotate?.addAngularVelocity(1, for: self.recordingSpinner)
            rotate2?.addAngularVelocity(-1, for: self.recordingSpinnerInner)
            animator.addBehavior(rotate!)
            animator.addBehavior(rotate2!)
        }
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
//    private func createAnimation() {
//        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 4, delay: 0, options: [.curveLinear,.allowUserInteraction], animations: {
//            UIView.animateKeyframes(withDuration: 4, delay: 0, animations: {
//                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0 / 3.0) {
//                    self.recordingSpinner.transform = .init(rotationAngle: .pi * 2 * 1 / 3)
//                }
//                UIView.addKeyframe(withRelativeStartTime: 1.0 / 3.0, relativeDuration: 1.0 / 3.0) {
//                    self.recordingSpinner.transform = .init(rotationAngle: .pi * 2 * 2 / 3)
//                }
//                UIView.addKeyframe(withRelativeStartTime: 2.0 / 3.0, relativeDuration: 1.0 / 3.0) {
//                    self.recordingSpinner.transform = .identity
//                }
//            })
//        }, completion: { [weak self] _ in
//            self?.createAnimation()
//        })
//    }

    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        let captureDevice = AVCaptureDevice.default(for:.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for:.audio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
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
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            //animator?.startAnimation()
            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }

            let outputFileName = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
            movieOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            //animator?.pauseAnimation()
            movieOutput.stopRecording()
        }
    }
    
    @IBAction func unwindToCamera(sender: UIStoryboardSegue) {
    }
    
    
}
extension CameraViewController: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            self.footageURL = outputFileURL as URL
            //print(self.videoRecorded!)
            self.performSegue(withIdentifier: "TrimFootage_Segue", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "TrimFootage_Segue" {
            let controller = segue.destination as! TrimFootageViewController
            controller.footageURL = self.footageURL
        }
    }
}

