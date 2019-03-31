//
//  SpeechViewController.swift
//  VisionAssistant
//
//  Created by Anish Palvai on 3/30/19.
//  Copyright © 2019 Anish Palvai. All rights reserved.
//
import UIKit
import AVFoundation

class Speech: UIViewController {
    
    let synth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func stringToSpeech(speech:String) {
        utterance = AVSpeechUtterance(string: speech)
        utterance.rate = 0.5
        synth.speak(utterance)
    }
    
    
    
}
