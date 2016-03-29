//
//  AudioStatus.swift
//  PenguinPet
//
//  Created by Tomer Buzaglo on 29/03/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation

var appHasMicAccess = true

enum AudioStatus: Int, CustomStringConvertible {
    case Stopped = 0,
    Playing,
    Recording
    
    var audioName: String {
        let audioNames = [
            "Audio: Stopped",
            "Audio:Playing",
            "Audio:Recording"]
        return audioNames[rawValue]
    }
    
    var description: String {
        return audioName
    }
}
