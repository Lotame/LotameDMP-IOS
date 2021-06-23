//
//  ViewController.swift
//  LotameDMP
//
//  Created by Dan Rusk on 09/23/2015.
//  Copyright (c) 2015 Lotame. All rights reserved.
//

import UIKit
import LotameDMP

class ViewController: UIViewController {

    @IBOutlet var uuid: UILabel!
    @IBOutlet var audienceData: UILabel!
    
    @IBOutlet var behaviorField: UITextField!
    @IBOutlet var valueField: UITextField!
    
    
    fileprivate var foregroundNotification: NSObjectProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        foregroundNotification = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            self.showUUID()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showUUID()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(foregroundNotification ?? "")
    }
    
    func showUUID(){
        uuid.text = DMP.advertisingId
        
        if !DMP.trackingEnabled{
            uuid.text = "Tracking disabled 'Limit Ad Tracking' is on"
        }
    }
    
    @IBAction func addBehavior(_ sender: UIButton) {
        self.view.endEditing(true)
        if let behavior = behaviorField.text{
            DMP.addBehaviorData(valueField.text, forType: behavior)
            
            let value = valueField.text ?? ""
            var output = audienceData.text ?? ""
            output += "\n\(behavior)=\(value)"
            audienceData.text = output
            behaviorField.text = ""
            valueField.text = ""
        }
    }
    
    @IBAction func sendBehaviors(_ sender: UIButton) {
        self.view.endEditing(true)
        DMP.sendBehaviorData(){
            result in
            if result.isSuccess{
                self.audienceData.text = "Data sent"
            } else {
                self.audienceData.text = "An error occurred \(result.error!)"
            }
        }
    }
    
    @IBAction func getAudience(_ sender: AnyObject) {
        self.view.endEditing(true)
        DMP.getAudienceData{
            result in
            if let profile = result.value{
                print("JSON Audience result:" + result.value!.jsonString!)
                var audiences = ""
                if profile.panoramaId != "" {
                    audiences += "PanoramaId : \(profile.panoramaId)"
                }
                for audience in profile.audiences{
                    if !audiences.isEmpty{
                        audiences += "; "
                    }else{
                        audiences += "Audiences: "
                    }
                    audiences += "id=\(audience.id), abbr=\(audience.abbreviation)"
                }
                
                if audiences.isEmpty{
                    audiences = "No audiences found for Advertising ID"
                }
                
                self.audienceData.text = audiences
            } else {
                self.audienceData.text = "An error occurred \(result.error!)"
            }
        }
        
    }

    @IBAction func startNewSession(_ sender: AnyObject) {
        DMP.startNewSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

