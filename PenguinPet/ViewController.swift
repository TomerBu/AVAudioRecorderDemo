//
//  ViewController.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 1/13/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //MARK: State Variables
    var audioStatus = AudioStatus.Stopped
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var currentFileUrl:NSURL?
    
    //MARK: IBOutlets
    @IBOutlet weak var penguin: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    //MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
    }
    
    //hide Status bar (Battery Bar)
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Controls
    @IBAction func onRecord(sender: UIButton) {
        //if we don't have micAccess - disable the button, show an alert & return
        guard appHasMicAccess else {
            recordButton.enabled = false
            dispAlert(title: "Requires Microphone Access",
                      message: "Go to Settings > PenguinPet > Allow PenguinPet to Access Microphone.\nSet switch to enable.",
                      defaultActionTitle: "OK", defaultActionHandler: nil)
            return
        }
        
        //can't record while playing
        guard audioStatus != .Playing else {/*disp alert */ return}
        
        //if stopped -> record(), else -> stopRecording()
        audioStatus == .Stopped ? record() : stopRecording()
    }
    
    @IBAction func onPlay(sender: UIButton) {
        //can't play while recording
        guard audioStatus != .Recording else {/*disp alert;*/ return}
        
        //if stopped -> play(), else -> stop()
        audioStatus == .Stopped ? play() : stopPlayback()
    }
    
    var updateTimer:CADisplayLink!
    
    func startUpdateLoop() {
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        updateTimer = CADisplayLink(target: self, selector:
            #selector(ViewController.updateLoop))
        updateTimer.frameInterval = 1
        updateTimer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode:
            NSRunLoopCommonModes)
    }
    
    func stopUpdateLoop() {
        updateTimer.invalidate()
        updateTimer = nil
        // Update UI
        timeLabel.text = formatTime(0)
    }
    
    func updateLoop() {
        guard audioStatus != .Stopped else{return}
        
        let text = audioStatus == .Playing ?
            formatTime(audioPlayer.currentTime) :
            formatTime(audioRecorder.currentTime)
        
        timeLabel.text =  text
    }
}



// MARK: - AVFoundation Methods
extension ViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    // MARK: Recording
    func setupRecorder() {
        currentFileUrl = getURLforFile("Memo", ext: ".caf")
        
        //public typealias AudioFormatID = UInt32
        let recordSettings:[String:AnyObject] = [AVFormatIDKey : Int(kAudioFormatLinearPCM),
                                                 AVSampleRateKey: 44100.0,
                                                 AVNumberOfChannelsKey: 2,
                                                 AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do{
            try audioRecorder = AVAudioRecorder(URL: currentFileUrl!, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        }
        catch let e as NSError{
            print(e.localizedDescription)
        }
    }
    
    func record() {
        changeImage(forButton: recordButton, withImage: "button-record1")
        audioStatus = .Recording
        audioRecorder.record()
        startUpdateLoop()
    }
    
    func stopRecording() {
        changeImage(forButton: recordButton, withImage: "button-record")
        audioStatus = .Stopped
        audioRecorder.stop()
        stopUpdateLoop()
    }
    
    // MARK: Playback
    func  play() {
        if let currentFileUrl = currentFileUrl{
            
            do{
                try audioPlayer = AVAudioPlayer(contentsOfURL: currentFileUrl)
                audioPlayer.delegate = self
                if audioPlayer.duration > 0.0 {
                    changeImage(forButton: playButton, withImage: "button-play1")
                    audioStatus = .Playing
                    audioPlayer.play()
                    startUpdateLoop()
                }
            }
            catch let e as NSError{
                print(e.localizedDescription)
            }
        }
        
    }
    
    func stopPlayback() {
        changeImage(forButton: playButton, withImage: "button-play")
        audioStatus = .Stopped
        
        if let player = audioPlayer{
            player.stop()
            stopUpdateLoop()
        }
    }
    
    // MARK: Delegates
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
    }
    // MARK: Notifications
    
    // MARK: - Helpers
    
    
}




