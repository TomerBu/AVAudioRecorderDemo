//
//  OptionsViewController.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 12/17/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
  
    @IBOutlet weak var volumeSlider: UISlider!{
        didSet{
            volumeSlider.setThumbImage(UIImage(named: "button-settings"), forState: UIControlState.Normal)
            volumeSlider.setThumbImage(UIImage(named: "button-settings"), forState: UIControlState.Highlighted)
        }
    }
  @IBOutlet weak var panSlider: UISlider!
  @IBOutlet weak var rateSlider: UISlider!
  @IBOutlet weak var loopSwitch: UISwitch!
  
  let defaults = NSUserDefaults.standardUserDefaults()
  weak var vc: ViewController!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    volumeSlider.value = defaults.floatForKey("Volume")
    panSlider.value = defaults.floatForKey("Pan")
    rateSlider.value = defaults.floatForKey("Rate")
    loopSwitch.on = defaults.boolForKey("Loop Audio")
    
  }
  
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  @IBAction func closeOptions(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func setVolume(sender: UISlider) {
    defaults.setFloat(sender.value, forKey: "Volume")
    defaults.synchronize()
    vc.setVolume(sender.value)
  }
  
  @IBAction func setPan(sender: UISlider) {
    defaults.setFloat(sender.value, forKey: "Pan")
    defaults.synchronize()
    vc.setPan(sender.value)
  }
  
  @IBAction func setRate(sender: UISlider) {
    defaults.setFloat(sender.value, forKey: "Rate")
    defaults.synchronize()
    vc.setRate(sender.value)
  }
  
  @IBAction func loopAudio(sender: UISwitch) {
    defaults.setBool(sender.on, forKey: "Loop Audio")
    defaults.synchronize()
    vc.setLoopPlayback(sender.on)
  }
  
  @IBAction func previewAudio(sender: UIButton) {
    vc.play()
  }
  
}
