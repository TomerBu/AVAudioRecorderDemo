//
//  MeterTable.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 12/17/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import Foundation

class MeterTable {
    let minDb: Float = -160
    var tableSize: Int // 300
    
    var meterTable = [Float]()
    
    init (tableSize: Int) { //tableSize = 100
        self.tableSize = tableSize
        
        let minAmp = dbToAmplitude(minDb) // the voltage that gives -160db ~ 9.99999994e-09
        
        for i in 0..<tableSize {
            //linear line that returns values between 0 and -160 for i = 0...100
            let decibels = Float(i) * Float(minDb) / Float(tableSize - 1) //when i = tableSize - 1 we get -160
            //(0...100) * 160 / 100
            //the voltage that gives this amplitude
            let amp = dbToAmplitude(decibels)
            //let adjAmp = amp / (1.0 - minAmp) //useless 1 - 9.99999994e-09 ~ 0.99999999999999.   we can also mult amp by 1.0000000001
            meterTable.append(amp)
//            
//            print("decibels \(decibels)", "amp: \(amp)","adjAmp:\(adjAmp)", "ampDelta: \(amp - minAmp)", "minAmp:\(minAmp)")
//            print("valueForPower \(valueForPower(decibels))")
        }
        
    }
    
    private func dbToAmplitude(dB: Float) -> Float {
        //decibels to amplitude value:
        // Converts given |db| value to its amplitude equivalent where 'dB = 20 * log10(amplitude)'.
        //db = 20Log10(V/V0) = 10Log10(I/I0) -> get the voltage of the amplitude from the decibel value
        //db = 20Log10(V) => Log10(V) = db / 20 => V = 10^(db/20) => V = 10^0.05*db
        return powf(10.0, 0.05 * dB)
    }
    
    func valueForPower(power: Float) -> Float {
        let power = min(max(minDb, power), 0) //power must be between 0 & -160 db
        
        let index = Int(power * (Float(tableSize - 1) / minDb))
        return meterTable[index]
        
    }
}