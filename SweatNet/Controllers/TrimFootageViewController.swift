//
//  TrimFootageViewController.swift
//  SweatNet
//
//  Created by Alex on 3/15/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

import UIKit
import AVFoundation
import os.log
import MobileCoreServices
import Photos

class TrimFootageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ThumbSelectorViewDelegate {
    
    func didChangeThumbPosition(_ imageTime: CMTime) {
        playerView.player?.seek(to: imageTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
//    let imagePicker = UIImagePickerController()

    @objc let player = AVPlayer()
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    var currentTime: Double {
        get {
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var selectThumbView: ThumbSelectorView!

    
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            trimmerView.asset = asset
            trimmerView.delegate = self
            selectThumbView.asset = asset
            selectThumbView.delegate = self
            trimmerView.handleColor = UIColor.white
            trimmerView.mainColor = UIColor.gray
            trimmerView.positionBarColor = UIColor.white
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
    

    var trimmerPositionChangedTimer: Timer?
    var playbackTimeCheckerTimer: Timer?
    
    var footageURL: URL?
    var videoURL: URL?
    var mediaDate: Date?
    var screenshotOut:UIImage?
    var thumbnailImage:UIImage?

    private var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    private var playerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            player.replaceCurrentItem(with: self.playerItem)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        //addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        
        playerView.playerLayer.player = player
        self.navigationController?.navigationBar.isHidden = false
        super.viewDidAppear(animated)
        guard let footageURL = self.footageURL else {return}
        asset = AVURLAsset(url: footageURL, options: nil)
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
//        self.navigationController?.navigationBar.tintColor = .white
    } 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = .white
    }
    override func viewDidLoad() {
       // imagePicker.delegate = self
        super.viewDidLoad()
        let segmentedControl = UISegmentedControl(items: ["Video","Screenshot"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor(red:0.35, green:0.78, blue:0.98, alpha:1.0)
        segmentedControl.addTarget(self, action: #selector(changedMode), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonPressed))
    }
    
    @objc func changedMode(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
        //set to video mode
        trimmerView.isHidden = false
        selectThumbView.isHidden = true
        MyVariables.isScreenshot = false
    case 1:
        //set to screenshot mode
        playerView.player?.pause()
        trimmerView.isHidden = true
        selectThumbView.isHidden = false
        MyVariables.isScreenshot = true
    default:
        //do nothing
        print("oops")
    }
    }
    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        /*
         Using AVAsset now runs the risk of blocking the current thread (the
         main UI thread) whilst I/O happens to populate the properties. It's
         prudent to defer our work until the properties we need have been loaded.
         */
        newAsset.loadValuesAsynchronously(forKeys: TrimFootageViewController.assetKeysRequiredToPlay) {
            /*
             The asset invokes its completion handler on an arbitrary queue.
             To avoid multiple threads using our internal state at the same time
             we'll elect to use the main thread at all times, let's dispatch
             our handler to the main queue.
             */
            DispatchQueue.main.async {
                /*
                 `self.asset` has already changed! No point continuing because
                 another `newAsset` will come along in a moment.
                 */
                guard newAsset == self.asset else { return }
                
                /*
                 Test whether the values of each of the keys we need have been
                 successfully loaded.
                 */
                for key in TrimFootageViewController.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                        
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        
                        self.handleErrorWithMessage(message, error: error)
                        
                        return
                    }
                }
                
                // We can't play this asset.
                if !newAsset.isPlayable || newAsset.hasProtectedContent {
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
                    
                    self.handleErrorWithMessage(message)
                    
                    return
                }
                
                /*
                 We can play this asset. Create a new `AVPlayerItem` and make
                 it our player's current item.
                 */
                self.playerItem = AVPlayerItem(asset: newAsset)
                print("loaded item")
            }
        }
    }
    func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
        NSLog("Error occured with message: \(String(describing: message)), error: \(String(describing: error)).")
        
        let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
        let defaultAlertMessage = NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
        
        let alert = UIAlertController(title: alertTitle, message: message == nil ? defaultAlertMessage : message, preferredStyle: UIAlertControllerStyle.alert)
        
        let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
        
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func startPlaybackTimeChecker() {
        
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(TrimFootageViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    typealias TrimPoints = [(CMTime, CMTime)]
    typealias TrimCompletion = () -> Void
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    func removeFileAtURLIfExists(url: URL) {
        
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        }
        catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
    func trimVideo (sourceURL: URL, destinationURL: URL, trimPoints: TrimPoints, completion: @escaping () -> ()) {
        
        guard sourceURL.isFileURL else { return }
        guard destinationURL.isFileURL else { return }
        
        let options = [
            AVURLAssetPreferPreciseDurationAndTimingKey: true
        ]
        
        let asset = AVURLAsset(url: sourceURL, options: options)
        let preferredPreset = AVAssetExportPresetPassthrough
        
        if  verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            
            let composition = AVMutableComposition()
            let videoCompTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
            let audioCompTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
            
            guard let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first else { return }
            guard let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first else { return }
            
            var accumulatedTime = kCMTimeZero
            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                let timeRangeForCurrentSlice = CMTimeRangeMake(startTimeForCurrentSlice, durationOfCurrentSlice)
                
                do {
                    try videoCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                    try audioCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                    accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
                }
                catch let compError {
                    print("TrimVideo: error during composition: \(compError)")
                }
            }
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset) else { return }
            
            exportSession.outputURL = destinationURL as URL
            exportSession.outputFileType = AVFileType.m4v
            exportSession.shouldOptimizeForNetworkUse = true
            
            removeFileAtURLIfExists(url: destinationURL as URL)
            
            exportSession.exportAsynchronously {
                completion()
            }
        }
        else {
            print("TrimVideo - Could not find a suitable export preset for the input video")
        }
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime else {
            return
        }
        
        let playBackTime = self.player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            self.player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            trimmerView.seek(to: startTime)
        }
    }
    func imageFromVideo(url: URL, time: CMTime) -> UIImage? {
        let asset = AVURLAsset(url: url)
        
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGeneratorApertureMode.encodedPixels
        
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: time, actualTime: nil)
        } catch let error {
            print("Error: \(error)")
            return nil
        }
        
        return UIImage(cgImage: thumbnailImageRef)
    }
    
    func prepareScreenshot() {
        guard let currentTime = selectThumbView.selectedTime else {
            return
        }
        self.screenshotOut = imageFromVideo(url: footageURL!, time: currentTime )
        self.thumbnailImage = self.screenshotOut
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "CreatePost_Segue", sender: nil)
        }
    }

    func prepareVideo(){
        let outputFileName = NSUUID().uuidString
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
        self.videoURL = URL(fileURLWithPath: outputFilePath)
        trimVideo(sourceURL: self.footageURL!, destinationURL: self.videoURL!, trimPoints: [(trimmerView.startTime!,trimmerView.endTime!)], completion: prepareVideoThumbnail)
    }
    func prepareVideoThumbnail() {
        guard let VideoURL = self.videoURL else { return }
        self.thumbnailImage = setThumbnailFrom(path: VideoURL)
        DispatchQueue.main.async {
          print("Dispatching")
          self.performSegue(withIdentifier: "CreatePost_Segue", sender: nil)
        }
    }

    @objc func nextButtonPressed() {
        if MyVariables.isScreenshot == true {
            print("is screenshot")
            prepareScreenshot()
        } else {
            print("isn't screenshot")
            prepareVideo()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //dismiss(animated: true, completion: nil)
        guard info[UIImagePickerControllerMediaType] != nil else { return }
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        print("video is",mediaType)
        switch mediaType {
        case kUTTypeImage:
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let pickedAsset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                self.screenshotOut = pickedImage
                MyVariables.isScreenshot = true
                self.thumbnailImage = pickedImage
                let creationDate = pickedAsset.creationDate
                self.mediaDate = creationDate
                dismiss(animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  {
                    
                    self.performSegue(withIdentifier: "CreatePost_Segue", sender: nil)
                    
                }
            }
            break
        case kUTTypeMovie:
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL,let pickedAsset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                print("KUMOVIE")
                MyVariables.isScreenshot = false
                let creationDate = pickedAsset.creationDate
                asset = AVURLAsset(url: videoURL, options: nil)
                self.footageURL = videoURL
                self.mediaDate = creationDate
                self.thumbnailImage = setThumbnailFrom(path: videoURL)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CreatePost_Segue", sender: nil)
                }
                self.videoURL = videoURL
                dismiss(animated: true, completion: nil)
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
//    @IBAction func importButtonPressed(_ sender: Any) {
//        PHPhotoLibrary.requestAuthorization({status in
//            switch status {
//            case .authorized:
//                self.imagePicker.sourceType = .photoLibrary
//                self.imagePicker.allowsEditing = true
//                self.imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
//
//                self.present(self.imagePicker,animated: true, completion: nil)
//            case .denied:
//                print("denied")
//            // probably alert the user that they need to grant photo access
//            case .notDetermined:
//                print("not determined")
//            case .restricted:
//                print("restricted")
//                // probably alert the user that photo access is restricted
//            }
//        })
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "CreatePost_Segue" {
            guard self.thumbnailImage != nil else {
                return
            }
            if MyVariables.isScreenshot == true {
                guard self.screenshotOut != nil else {
                    return
                }
                //self.performSegue(withIdentifier: "CreatePost_Segue", sender: nil)
            } else {
                guard self.thumbnailImage != nil else {
                    return
                }
                //self.performSegue(withIdentifier: "CreatePost_Segue", sender: nil)
                //now I set those three varibles?
            }
            let controller = segue.destination as! CreatePostViewController
            controller.postDate = mediaDate
            controller.thumbnailImage = thumbnailImage
            controller.videoURL = videoURL
            controller.screenshotOut = screenshotOut
            print("segued",MyVariables.isScreenshot)

        }
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
    @IBAction func unwindToTrimFootage(sender: UIStoryboardSegue) {
    }
}

extension TrimFootageViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        player.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player.pause()
        player.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        //let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        //print(duration)
    }
    
    func playerStatus(){
        print(player.rate)
    }
    func pausePlayer(){
        player.pause()
    }
}

