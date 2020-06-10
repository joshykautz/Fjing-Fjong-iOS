//
//  PlayController.swift
//  Fjing Fjong
//
//  Created by Fjorge Developers on 3/20/20.
//  Copyright © 2020 Fjorge. All rights reserved.
//

import Foundation
import AVFoundation
import HaishinKit
import Photos
import UIKit
import VideoToolbox
import Logboard
import MetalKit

class PlayController: UIViewController {
    
    @IBOutlet weak var LiveFeedGLHKView: MTHKView!
    @IBOutlet weak var RecordUIButton: UIButton!
    @IBOutlet weak var AddUIButton: UIButton!
    
    private var appDelegate : AppDelegate!
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var add: Bool = false
            
    @IBAction func toggleStream(_ sender: Any) {
        if (appDelegate.isStreaming) {
            stopBroadcast()
            appDelegate.willStream = false
            let ScoreViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScorePopUp") as! ScorePopUpViewController
            self.present(ScoreViewController, animated: true)
        }
        else {
            appDelegate.willStream = true
            let PlayerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerPopUp") as! PlayerPopUpViewController
            self.present(PlayerViewController, animated: true)
        }
    }
    
    func stopBroadcast(){
        appDelegate.isStreaming = false
        rtmpConnection.close()
        RecordUIButton.tintColor = UIColor.white
        RecordUIButton.setBackgroundImage(UIImage(systemName: "video.slash.fill"), for: .normal)
        RecordUIButton.imageView?.contentMode = .scaleAspectFit
        RecordUIButton.frame.size = CGSize(width: 44,height: 35)
        AddUIButton.isEnabled = true
    }
    
    func startBroadcast(){
        // TODO: Set Twitch channel title to be date, and the name of players.
        // https://dev.twitch.tv/docs/v5/reference/channels/#update-channel
        appDelegate.isStreaming = true
        rtmpConnection.connect("")
        rtmpStream.publish("")
        RecordUIButton.tintColor = UIColor.red
        RecordUIButton.setBackgroundImage(UIImage(systemName: "video.fill"), for: .normal)
        RecordUIButton.imageView?.contentMode = .scaleAspectFit
        RecordUIButton.frame.size = CGSize(width: 44,height: 20)
        AddUIButton.isEnabled = false
    }
    
    @IBAction func addPressed(_ sender: Any) {
        // TODO: Pop up view ask for players and score of game.
        // TODO: Have pop up view save the match using Fjing Fjong API
        
        let PlayerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerPopUp") as! PlayerPopUpViewController
        self.present(PlayerViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                
        rtmpStream = RTMPStream(connection: rtmpConnection)
                
        rtmpStream.captureSettings = [
            .fps: 60, // FPS
            .sessionPreset: AVCaptureSession.Preset.high, // input video width/height
            // .isVideoMirrored: false,
             .continuousAutofocus: true, // use camera autofocus mode
            // .continuousExposure: false, //  use camera exposure mode
            .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.cinematicExtended
        ]
        rtmpStream.audioSettings = [
            .muted: false, // mute audio
            .bitrate: 1024 * 1024,
        ]
        
        let orientation = DeviceUtil.videoOrientation(by: (UIApplication.shared.windows.first?.windowScene!.interfaceOrientation)!)!
        
        rtmpStream.orientation = orientation
        
        switch orientation {
            case AVCaptureVideoOrientation.landscapeLeft,
                 AVCaptureVideoOrientation.landscapeRight:
               rtmpStream.videoSettings = [
                .width: 1280, // video output width
                .height: 720, // video output height
                .bitrate: 1024 * 1024,
               ]
            default:
               rtmpStream.videoSettings = [
                .width: 720, // video output width
                .height: 1280, // video output height
                .bitrate: 1024 * 1024,
               ]
        }

        NotificationCenter.default.addObserver(self, selector: #selector(on(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc
    private func on(_ notification: Notification) {
        let orientation = DeviceUtil.videoOrientation(by: (UIApplication.shared.windows.first?.windowScene!.interfaceOrientation)!)!
        
        rtmpStream.orientation = orientation
        
        switch orientation {
            case AVCaptureVideoOrientation.landscapeLeft,
                 AVCaptureVideoOrientation.landscapeRight:
               rtmpStream.videoSettings = [
                .width: 1280, // video output width
                .height: 720, // video output height
               ]
            default:
               rtmpStream.videoSettings = [
                .width: 720, // video output width
                .height: 1280, // video output height
               ]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
            // print(error)
        }
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
            // print(error)
        }

        LiveFeedGLHKView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        LiveFeedGLHKView.attachStream(rtmpStream)
    }
  
}
