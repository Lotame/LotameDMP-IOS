//
//  ViewController.swift
//  LotameDMP
//
//  Created by Dan Rusk on 09/23/2015.
//  Copyright (c) 2015 Dan Rusk. All rights reserved.
//

import UIKit
import LotameDMP

class ViewController: UIViewController {

    @IBOutlet var uuid: UILabel!
    @IBOutlet var audienceData: UILabel!
    
    @IBOutlet var behaviorField: UITextField!
    @IBOutlet var valueField: UITextField!
    
    
    private var foregroundNotification: NSObjectProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            self.showUUID()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        showUUID()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(foregroundNotification)
    }
    
    func showUUID(){
        uuid.text = DMP.advertisingId
        
        if !DMP.trackingEnabled{
            uuid.text = "Tracking disabled 'Limit Ad Tracking' is on"
        }
    }
    
    @IBAction func addBehavior(sender: UIButton) {
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
    
    @IBAction func sendBehaviors(sender: UIButton) {
        self.view.endEditing(true)
        do {
            try DMP.sendBehaviorData(){
                err in
                if let err = err{
                    self.audienceData.text = "An error occurred \(err)"
                } else {
                    self.audienceData.text = "Data sent"
                }
            }
        } catch LotameError.InitializeNotCalled {
            audienceData.text = "Need to initialize with client id before calling send"
        } catch {
            audienceData.text = "An error occurred"
        }
    }
    
    @IBAction func getAudience(sender: AnyObject) {
        self.view.endEditing(true)
        do{
            try DMP.getAudienceData{
                profile, err in
                if let profile = profile{
                    var audiences = ""
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
                    self.audienceData.text = "An error occurred \(err!)"
                }
            }
        }catch LotameError.InitializeNotCalled {
            audienceData.text = "Need to initialize with client id before calling extract"
        } catch {
            audienceData.text = "An error occurred"
        }
        
    }

    @IBAction func startNewSession(sender: AnyObject) {
        DMP.startNewSession()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

