//
//  ImagePreviewViewController.swift
//  VisionAssistant
//
//  Created by Anish Palvai on 3/30/19.
//  Copyright © 2019 Anish Palvai. All rights reserved.
//
import Foundation
import UIKit
import Vision
import CoreML
import FirebaseDatabase
import FirebaseMLVision
import Firebase
import AVFoundation
import Speech

class ImagePreview: UIViewController {
    
    let resnet = Resnet50()
    var imagePicker = UIImagePickerController()
    var detect = Speech()
    var ref:DatabaseReference!
    var observations:[String] = []
    var DatabaseHandle: DatabaseHandle?
    
    var index:Int = 0
    
    @IBOutlet weak var speechLabel: UILabel!
    
    public var capturedImage: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    let audioEngine = AVAudioEngine()
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    let request = SFSpeechAudioBufferRecognitionRequest()
    
    var recognitionTask: SFSpeechRecognitionTask?
    
    var detectedObject: String = ""
    var databaseHandle:DatabaseHandle = 0
    
   
    var textRecognizer: VisionTextRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        
        imageView.image = capturedImage
        
        if let image = capturedImage{
            processPic(image: image)
        }
        
        ref = Database.database().reference()
    }
    
    func processPic(image: UIImage){
        if let model = try? VNCoreMLModel(for: resnet.model){
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation]{
                    self.detectedObject = results[0].identifier
                    self.detect.stringToSpeech(speech: "This object is a \(self.detectedObject)")
                    
                    let visionImage = VisionImage(image: image)
                    
                    /* self.textRecognizer.process(visionImage, completion: { (text, error) in
                        guard error == nil, let result = text else {
                            return
                        }
                        self.detect.stringToSpeech(speech: result.text)
                    })
 */
 
                }
            }
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
            
        }
        
    }
    
    @IBAction func startRecording(_ sender: Any) {
       self.recordAndRecognizeSpeech()
    }
    
    func recordAndRecognizeSpeech(){
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
    }
        
        
        audioEngine.prepare()
            do{
                try? audioEngine.start()
                
                recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                    if let result = result{
                        self.speechLabel.text = result.bestTranscription.formattedString
                        if result.bestTranscription.formattedString.contains("copy"){
                            self.ref.child("users").setValue(["copied": result.bestTranscription.formattedString])
                            let stringResult = result.bestTranscription.formattedString.replacingOccurrences(of: "copy", with: "")
                            UIPasteboard.general.string = stringResult

                        }
                        if result.bestTranscription.formattedString.contains("paste"){
                            self.databaseHandle = self.ref.child("users").child("copied").observe(.value , with: { (snapshot) in
                                
                            })
                        }
                    } else if let error = error {
                        print(error)
                    }
                })
                
            }
            catch{
                print(error)
            }
        }
    }

