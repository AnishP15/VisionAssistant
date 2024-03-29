//
//  DetectedObjectsTableViewController.swift
//  VisionAssistant
//
//  Created by Anish Palvai on 3/30/19.
//  Copyright © 2019 Anish Palvai. All rights reserved.
//


import UIKit
import FirebaseDatabase

class DetectedObjects: UITableViewController {
    
    var speech = Speech()
    var imagePreview = ImagePreview()
    
    var observations:[String] = []
    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
       
        self.databaseHandle = self.ref.child("users").child("copied").observe(.value , with: { (snapshot) in
            
            let post = snapshot.value as? String
            let stringPost = post?.replacingOccurrences(of: "copy", with: "")
            if let actualPost = stringPost {
                self.observations.append(actualPost)
            }
            
            self.tableView.reloadData()
        })
    }
    
     override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
 
        cell.textLabel?.text = observations[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        
        let textToSpeak = currentCell.textLabel?.text
        
        speech.stringToSpeech(speech: textToSpeak!)
        tableView.deselectRow(at: indexPath!, animated: true)
    }
}
