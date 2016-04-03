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
    let meterTable = MeterTable(tableSize: 100)
    //MARK: State Variables
    var audioStatus = AudioStatus.Stopped{
        //State Machine with swift enums and property observers
        didSet{
            if oldValue == .Playing && audioStatus == .Stopped {
                //changed state from playing to stopped:)
            }
        }
    }
    
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
        registerNotifications()
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
        animateMouth(1)
    }
    
    func updateLoop() {
        guard audioStatus != .Stopped else{return}
        
        let text = audioStatus == .Playing ?
            formatTime(audioPlayer.currentTime) :
            formatTime(audioRecorder.currentTime)
        
        timeLabel.text =  text
        animateMouth(meterLevelesToFrame())
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
                                                 AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]
        
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
                audioPlayer.meteringEnabled = true
                audioPlayer?.enableRate = true
                setVolume(NSUserDefaults.standardUserDefaults().floatForKey("Volume"))
                setPan(NSUserDefaults.standardUserDefaults().floatForKey("Pan"))
                setLoopPlayback(NSUserDefaults.standardUserDefaults().boolForKey("Loop Audio"))
                setRate(NSUserDefaults.standardUserDefaults().floatForKey("Rate"))
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
    
    
    // MARK: - Helpers
}
// MARK: Handle Interruptions & RouteChanges (Devices un/plugged) with Notifications
extension ViewController{
    
    /*
     use the NSNotificationCenter & register to 2 events:
     1) Audio Interruptions - other devices are playing, call entered etc
     2) Audio Route(device) Changed - headPhones un/plugged etc
     */
    func registerNotifications(){
        let session = AVAudioSession.sharedInstance()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: #selector(self.handleInterruption(_:)), name: AVAudioSessionInterruptionNotification, object: session)
        
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSessionRouteChangeNotification, object: session)
    }
    
    
    func handleInterruption(notification: NSNotification){
        let info = notification.userInfo!
        
        let interruptionTypeRawValue = info[AVAudioSessionInterruptionTypeKey] as! UInt
        let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeRawValue)!
        
        switch interruptionType {
        case .Began:
            //what we actually need is a pause method
            //so that we can come back from this interruption
            stopRecording()
            stopPlayback()
        case .Ended:
            //interruption just ended - test the interruptionOptions
            //to see if we should resume playback. if it's a game we should always resume playback.
            let interruptionOptionsRawValue = info[AVAudioSessionInterruptionOptionKey] as! UInt
            let interruptionOptions = AVAudioSessionInterruptionOptions(rawValue: interruptionOptionsRawValue)
            
            if interruptionOptions == .ShouldResume {
                /*
                 we need to save some state to detrmine
                 resume playback or resume recording.
                 maybe we can dialog the user...
                 */
            }
        }
        
    }
    /*
     test the notification for the RouteChangeReason
     if the reason is .OldDeviceUnavailable
     we want to know if the old device was headphones:
     if so, the headphones were unplugged -> stop recording & stop playback
     */
    func handleRouteChange(notification: NSNotification){
        let info = notification.userInfo!
        
        let reasonRawValue = info[AVAudioSessionRouteChangeReasonKey] as! UInt
        let reason = AVAudioSessionRouteChangeReason(rawValue: reasonRawValue)!
        
        //if an old device is unavailable we want to know which device was the previous. if
        //it's the headphones: we would like to stop recording and playing:
        guard reason == AVAudioSessionRouteChangeReason.OldDeviceUnavailable else {return}
        
        let prevRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription
        
        if prevRoute.outputs[0].portType == AVAudioSessionPortHeadphones {
            stopPlayback()
            stopRecording()
        }
    }
    /*
     
     //there is a reason (AVAudioSessionRouteChangeReason)
     //the reason can be:
     
     AVAudioSessionRouteChangeReason.CategoryChange
     //The category of the session object changed. Also used when the session is first activated.
     
     AVAudioSessionRouteChangeReason.NewDeviceAvailable
     //A user action (such as plugging in a headset) has made a preferred audio route available.
     
     AVAudioSessionRouteChangeReason.NoSuitableRouteForCategory
     //The route changed because no suitable route is now available for the specified category.
     
     AVAudioSessionRouteChangeReason.OldDeviceUnavailable
     //The previous audio output path is no longer available.
     
     AVAudioSessionRouteChangeReason.RouteConfigurationChange
     //The set of input and output ports has not changed, but their configuration has—for example, a port’s selected data source has changed.
     AVAudioSessionRouteChangeReason.WakeFromSleep
     //The route changed when the device woke up from sleep.
     */
}


extension ViewController{
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "optionsSeque" {
            let optionsVC = segue.destinationViewController as! OptionsViewController
            optionsVC.vc = self
        }
    }
    
    func setVolume(value: Float) {
        audioPlayer?.volume = value //0 - 1
    }
    
    //Panning audio lets you distribute sound across the stereo channels
    func setPan(value: Float) {
        audioPlayer?.pan = value//left-1 - +1 //right
        //zero = center
    }
    //change the playBack rate
    func setRate(value: Float) {
        audioPlayer?.rate = value
    }
    
    func setLoopPlayback(loop: Bool) {
        audioPlayer.numberOfLoops = loop ? -1 : 0
        //negative value - infinite num of repeats
        //1 - repeat once. 0 - don't repeat
    }
    func meterLevelesToFrame()-> Int{
        audioPlayer?.updateMeters()
        let avgPower = audioPlayer?.averagePowerForChannel(0)
        var pow = audioPlayer?.peakPowerForChannel(0)
      
        let linearValue = meterTable.valueForPower(avgPower ?? -0)
        print(linearValue)
        //Convert to percentage
        //let pct = Int(round(linearValue * 100))
        let frame =  min(4, Int(round(60 * linearValue))) // 0 - 4
        print(frame)
        return frame + 1 // 1-5
    }
    
    func animateMouth(frame:Int){
        let frameName = "penguin_0\(frame)"
        let frameImage = UIImage(named: frameName)
        penguin.image = frameImage
    }
}



