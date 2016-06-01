//
//  InterfaceController.swift
//  geowahl-ios WatchKit Extension
//
//  Created by Patrick Eberhardt on 30.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    
    @IBOutlet var image: WKInterfaceImage!
    @IBOutlet var partyNameLabel: WKInterfaceLabel!
    @IBOutlet var locationNameLabel: WKInterfaceLabel!
    
    
    var session: WCSession!
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            print("Session is supported")
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            if session.reachable {
                print("Phone is reachable")
            } else {
                print("Phone is not reachable")
            }
        } else {
            print("Session is not supported")
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        let width = WKInterfaceDevice.currentDevice().screenBounds.width
        let height = WKInterfaceDevice.currentDevice().screenBounds.height
        
        // Create a graphics context
        let size = CGSizeMake(width, height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        UIColor.blueColor().setStroke()
        UIColor.blueColor().setFill()
        
        // Draw an oval
        let rect = CGRectMake(0, 0, width, height)
        let path = UIBezierPath(rect: rect)
        path.lineWidth = 4.0
        path.fill()
        path.stroke()
        
        // Convert to UIImage
        let cgimage = CGBitmapContextCreateImage(context);
        let uiimage = UIImage(CGImage: cgimage!)
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        image.setImage(uiimage)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("received")
        let key = userInfo["key"] as? String
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            if let key = key {
                self.partyNameLabel.setText("\(key)")
            }
        }
    }
    
    //    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    //        print("received")
    //        let key = applicationContext["key"] as? String
    //
    //        //Use this to update the UI instantaneously (otherwise, takes a little while)
    //        dispatch_async(dispatch_get_main_queue()) {
    //            if let key = key {
    //                self.partyNameLabel.setText("\(key)")
    //            }
    //        }
    //    }
    
}
