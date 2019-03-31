//
//  CameraViewController.swift
//  VisionAssistant
//
//  Created by Anish Palvai on 3/30/19.
//  Copyright © 2019 Anish Palvai. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseDatabase

@available(iOS 10.0, *)
class CameraView : UIViewController {
    
    let session = AVCaptureSession()
    var camera : AVCaptureDevice?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var cameraCaptureOutput : AVCapturePhotoOutput?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCaptureSession()
        
    }
    
    func displayCapturedPhoto(capturedPhoto : UIImage) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagePreviewViewController = storyboard.instantiateViewController(withIdentifier: "imagePreviewViewController") as! ImagePreview
        imagePreviewViewController.capturedImage = capturedPhoto
        navigationController?.pushViewController(imagePreviewViewController, animated: true)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        takePicture()
    }
    
    
    func initializeCaptureSession() {
        
        session.sessionPreset = AVCaptureSession.Preset.high
        camera = AVCaptureDevice.default(for: AVMediaType.video)
        
        
        do {
            if let cam = camera{
                let cameraCaptureInput = try AVCaptureDeviceInput(device: cam)
                cameraCaptureOutput = AVCapturePhotoOutput()
                
                session.addInput(cameraCaptureInput)
                session.addOutput(cameraCaptureOutput!)
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.bounds
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        session.startRunning()
    }
    
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        cameraCaptureOutput?.capturePhoto(with: settings, delegate: self)
    }
}

@available(iOS 10.0, *)
extension CameraView : AVCapturePhotoCaptureDelegate {
    
    @available(iOS 10.0, *)
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let unwrappedError = error {
            print(unwrappedError.localizedDescription)
        } else {
            
            if let sampleBuffer = photoSampleBuffer, let dataImage =
                
                AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                
                if let finalImage = UIImage(data: dataImage) {
                    
                    displayCapturedPhoto(capturedPhoto: finalImage)
                }
            }
        }
    }
}
