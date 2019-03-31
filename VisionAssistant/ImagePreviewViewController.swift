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
import FirebaseMLNLLanguageID
import FirebaseMLCommon

class ImagePreview: UIViewController {
    
    let resnet = Resnet50()
    var imagePicker = UIImagePickerController()
    var detect = Speech()
    var ref:DatabaseReference!
    var observations:[String] = []
    
    var index:Int = 0
    
    public var capturedImage: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    
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
                    
                    self.textRecognizer.process(visionImage) { result, error in
                        guard error == nil, let result = result else {
                            return
                        }
                        
                       let resultText = result.text
                        self.detect.stringToSpeech(speech: resultText)
                    }
              
                    
                }
            }
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
            
        }
        
    }
    

    
    @IBAction func saveString(_ sender: Any) {
        let deviceName = UIDevice.current.name
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        let dateString = dateFormatter.string(from: date)
        
        self.ref.child("iOS").child(deviceName).child("Objects").child(dateString).setValue(detectedObject)
        
    }
    
}

