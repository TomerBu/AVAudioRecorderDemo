//
//  Utils.swift


import UIKit


extension UIViewController{
    func changeImage(forButton btn :UIButton, withImage image :String){
        btn.setBackgroundImage(UIImage(named:image), forState: .Normal)
    }
}

extension UIViewController{
    func dispAlert(title title:String, message:String, defaultActionTitle:String?, defaultActionHandler: ((UIAlertAction)->Void)?){
        let mAlert = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: UIAlertControllerStyle.Alert)
        if let title = defaultActionTitle {
            mAlert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: defaultActionHandler))
        }
        presentViewController(mAlert, animated: true, completion:nil)
    }
}

func getURLforFile(name:String, ext:String) -> NSURL? {
    //trim dots (.) from the extension to prevent usage confusion
    let ext = ext.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
    
    //get the documents directory for our app
    let documentsDirectory:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    //Use a String formatter to get the time in a desired String representation
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss_SSS"
    
    //get the current timeStamp String from the formatter
    let timeStamp = formatter.stringFromDate(NSDate())
    
    //build a url from the components(dir, filename + timeStamp + .ext)
    return NSURL.fileURLWithPathComponents([documentsDirectory, "\(name)_\(timeStamp).\(ext)"])
}

func formatTime(time: NSTimeInterval) -> String {
    //NSTimeInterval is a typedef for double. it represents seconds
    //ie: 1.10471655328798 == 1 Second + fractions of a second
    
    let time = Int(time)
    
    //cut of all that is >= 60 //modulu property 61 will give us 1
    let seconds = time % 60
    //how many hours in minutes :)
    let hours = time / 3600
    //how many minutes -> cut of all that is >= 60 minutes
    let minutes = (time / 60) % 60
    
    return String(format: "%02d:%02d:%02d", arguments:   [hours, minutes, seconds])
}