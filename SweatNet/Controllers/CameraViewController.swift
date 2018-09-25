//
//  CameraController.swift
//  SweatNet
//
//  Created by Alex on 3/14/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import AVFoundation
import UIKit
import Photos
import MobileCoreServices

var captureSession: AVCaptureSession?
var videoPreviewLayer: AVCaptureVideoPreviewLayer?

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraButtonDelegate {
    
    func pressedPlay() {
        startRecording()
        startTimer()
    }
    
    func pressedPause() {
        stopRecording()
        stopTimer()
    }
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    let imagePicker = UIImagePickerController()

    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var footageURL: URL?
    
    var timeMin = 0
    var timeSec = 0
    weak var timer: Timer?
    var isPlaying = false

    
    //private var animator: UIViewPropertyAnimator?
//    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: view)
//    private var rotate: UIDynamicItemBehavior?
//    private var rotate2: UIDynamicItemBehavior?
//
//    @IBOutlet weak var recordingSpinnerInner: UIImageView!
//    @IBOutlet weak var recordingSpinner: UIImageView!
    @IBOutlet weak var cameraButton: CameraButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    var pickedPhoto: UIImage?
    var pickedPhotoThumbnail: UIImage?
    var pickedMovieURL: URL?
    var pickedMediaThumbnail: UIImage?
    var pickedMediaDate: Date?
    
    let squareLayer = CAShapeLayer()
    let circleLayer = CAShapeLayer()
    // Tells us if the current shape is a square
    var isSquare = false
    // Stores and sets the animation
    var layerAnimation = CABasicAnimation(keyPath: "path")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Camera"
//        self.recordingSpinner.isUserInteractionEnabled = true
        imagePicker.delegate = self
        cameraButton.delegate = self
//        importButton.layer.zPosition = 1
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        self.recordingSpinner.addGestureRecognizer(tap)
        if setupSession(){
            setupPreview()
            startSession()
        }
        
//        let layerCenter = playButton.center
//
//        // Setup the square layer & add it
//
//        let square = squarePathWithCenter(center: layerCenter, side: 100)
//        squareLayer.path = square.cgPath
//        squareLayer.fillColor = UIColor.red.cgColor
//
//        // Setup the circle layer
//        let circle = circlePathWithCenter(center: layerCenter, radius: 70)
//        circleLayer.path = circle.cgPath
//        circleLayer.fillColor = UIColor.red.cgColor
//        self.view.layer.addSublayer(circleLayer)
//
//
//        // Setup animation values that dont change
//        layerAnimation.duration = 0.3
//        // Sets the animation style. You can change these to see how it will affect the animations.
//        layerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        layerAnimation.fillMode = kCAFillModeForwards
//        // Dont remove the shape when the animation has been completed
//        layerAnimation.isRemovedOnCompletion = false
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // Get the first area we touched on the device
//        let touch = touches.first
//        // Get the point coordinates we touched on the device
//        let point = touch!.location(in: self.view)
//        // If we tapped on the circle or square then change the shape
//        if squareLayer.path!.contains(point) || circleLayer.path!.contains(point) {
//
//            if isSquare {
//                // If we have a square change the shape to a circle
//                layerAnimation.fromValue = squareLayer.path
//                layerAnimation.toValue = circleLayer.path
//                self.circleLayer.add(layerAnimation, forKey: "animatePath");
//            } else {
//                // If we have a circle change the shape to a square
//                layerAnimation.fromValue = circleLayer.path
//                layerAnimation.toValue = squareLayer.path
//                self.circleLayer.add(layerAnimation, forKey: "animatePath");
//            }
//            // Set isSquare to the opposite.
//            isSquare = !isSquare
//        }
//    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerLabel.text = String(format: "%02d:%02d", timeMin, timeSec)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetTimerToZero()
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
//    override func shouldAutorotate() -> Bool {
//
//        return false
//
//    }
    fileprivate func startTimer(){
        
        // if you want the timer to reset to 0 every time the user presses record you can uncomment out either of these 2 lines
        // timeSec = 0
        // timeMin = 0
        // If you don't use the 2 lines above then the timer will continue from whatever time it was stopped at
        let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
        timerLabel.text = timeNow
        
        stopTimer() // stop it at it's current time before starting it again
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.UpdateTimer()
        }
    }

    
    @objc func UpdateTimer() {
        timeSec += 1
        if timeSec == 60 {
            timeSec = 0
            timeMin += 1
        }
        let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
        timerLabel.text = timeNow
    }
    
    fileprivate func resetTimerToZero(){
        timeSec = 0
        timeMin = 0
        stopTimer()
    }
    
    fileprivate func resetTimerAndLabel(){
        resetTimerToZero()
        timerLabel.text = String(format: "%02d:%02d", timeMin, timeSec)
    }
    
    fileprivate func stopTimer(){
        timer?.invalidate()
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    func setThumbnailFrom(path: URL) -> UIImage? {
        
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
        
    }
    @IBAction func importButtonPressed(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization({status in
            switch status {
            case .authorized:
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = true
                self.imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]

                self.present(self.imagePicker,animated: true, completion: nil)
            case .denied:
                print("denied")
            // probably alert the user that they need to grant photo access
            case .notDetermined:
                print("not determined")
            case .restricted:
                print("restricted")
                // probably alert the user that photo access is restricted
            }
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //dismiss(animated: true, completion: nil)
        print("finished mediapicker")
        guard info[UIImagePickerControllerMediaType] != nil else { return }
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        print("video is",mediaType)
        switch mediaType {
        case kUTTypeImage:
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let pickedAsset = info[UIImagePickerControllerPHAsset] as? PHAsset {

                self.pickedPhoto = pickedImage
                MyVariables.isScreenshot = true
                self.pickedMediaThumbnail = pickedImage
                let creationDate = pickedAsset.creationDate
                self.pickedMediaDate = creationDate
                dismiss(animated: true) {
                    self.performSegue(withIdentifier: "CreatePostWithImportedMedia", sender: nil)
                }
            }
            break
        case kUTTypeMovie:
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL,let pickedAsset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                print("KUMOVIE")
                MyVariables.isScreenshot = false
                let creationDate = pickedAsset.creationDate
//                print("creationDate ",creationDate)
//                print("creationDate  ",pickedAsset)
                self.pickedMovieURL = videoURL
                self.pickedMediaDate = creationDate
                self.pickedMediaThumbnail = setThumbnailFrom(path: videoURL)
                dismiss(animated: true) {
                    self.performSegue(withIdentifier: "CreatePostWithImportedMedia", sender: nil)
                }
            }
            break
        case kUTTypeLivePhoto:
            print("livePhoto")
            dismiss(animated: true, completion: nil)

            break
        default:
            dismiss(animated: false, completion: nil)

            print("something else")
            break
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
//
//    @objc func handleTap(_ gesture:UITapGestureRecognizer) {
////        if animator == nil {
////            createAnimation()
////        }
//        startRecording()
//
//        if let rotate = rotate, let rotate2 = rotate2 {
//            animator.removeBehavior(rotate)
//            animator.removeBehavior(rotate2)
//            self.rotate = nil
//            self.rotate2 = nil
//        } else {
//            rotate = UIDynamicItemBehavior(items: [self.recordingSpinner])
//            rotate2 = UIDynamicItemBehavior(items: [self.recordingSpinnerInner])
//            rotate?.allowsRotation = true
//            rotate2?.allowsRotation = true
//            rotate?.angularResistance = 0
//            rotate2?.angularResistance = 0
//            rotate?.addAngularVelocity(1, for: self.recordingSpinner)
//            rotate2?.addAngularVelocity(-1, for: self.recordingSpinnerInner)
//            animator.addBehavior(rotate!)
//            animator.addBehavior(rotate2!)
//        }
//    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        camPreview.layer.addSublayer(previewLayer)
    }
//    override func viewWillLayoutSubviews() {
//
//        let orientation: UIDeviceOrientation = UIDevice.current.orientation
//
//        switch (orientation) {
//        case .portrait:
//            previewLayer?.connection?.videoOrientation = .portrait
//        case .landscapeRight:
//            previewLayer?.connection?.videoOrientation = .landscapeLeft
//        case .landscapeLeft:
//            previewLayer?.connection?.videoOrientation = .landscapeRight
//        default:
//            previewLayer?.connection?.videoOrientation = .portrait
//        }
//    }
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
            //timerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
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

    
//    func circlePathWithCenter(center: CGPoint, radius: CGFloat) -> UIBezierPath {
//        let circlePath = UIBezierPath()
//        circlePath.addArc(withCenter: center, radius: (radius - 20), startAngle: -CGFloat(Double.pi), endAngle: -CGFloat(M_PI/2), clockwise: true)
//        circlePath.addArc(withCenter: center, radius: (radius - 20), startAngle: -CGFloat(Double.pi/2), endAngle: 0, clockwise: true)
//        circlePath.addArc(withCenter: center, radius: (radius - 20), startAngle: 0, endAngle: CGFloat(Double.pi/2), clockwise: true)
//        circlePath.addArc(withCenter: center, radius: (radius - 20), startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(M_PI), clockwise: true)
//        circlePath.close()
//        return circlePath
//    }
//    
//    func squarePathWithCenter(center: CGPoint, side: CGFloat) -> UIBezierPath {
//        let squarePath = UIBezierPath()
//        let startX = center.x - side / 2
//        let startY = center.y - side / 2
//        squarePath.move(to: CGPoint(x: startX, y: startY))
//        squarePath.addLine(to: squarePath.currentPoint)
//        squarePath.addLine(to: CGPoint(x: startX + side, y: startY))
//        squarePath.addLine(to: squarePath.currentPoint)
//        squarePath.addLine(to: CGPoint(x: startX + side, y: startY + side))
//        squarePath.addLine(to: squarePath.currentPoint)
//        squarePath.addLine(to: CGPoint(x: startX, y: startY + side))
//        squarePath.addLine(to: squarePath.currentPoint)
//        squarePath.close()
//        return squarePath
//    }
//    
}
extension CameraViewController: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            print("Finished Recording")
            self.footageURL = outputFileURL as URL
            //print(self.videoRecorded!)
            self.performSegue(withIdentifier: "TrimFootage_Segue", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "TrimFootage_Segue" {
            let controller = segue.destination as! TrimFootageViewController
            controller.footageURL = self.footageURL
            controller.mediaDate = Date()

        } else if segue.identifier == "CreatePostWithImportedMedia" {
            guard self.pickedMediaThumbnail != nil else {
                return
            }
            let controller = segue.destination as! CreatePostViewController
            controller.postDate = self.pickedMediaDate
            controller.thumbnailImage = self.pickedMediaThumbnail
            controller.videoURL = self.pickedMovieURL
            controller.screenshotOut = self.pickedPhoto
        }
    }
}

