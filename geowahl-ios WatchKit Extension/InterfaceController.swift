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
    var percentArray : [Double] = []
    var namesArray : [String] = []
    var winnerColor: UIColor?
    
    enum Parties: String {
        case Griss
        case Hofer
        case Hundstorfer
        case Khol
        case Lugner
        case VdB
        case SPOE
        case FPOE
        case OEVP
        case GRUE
        case NEOS
        case FRANK
    }
    
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
        // Configure interface objects here.
    }
    
    func drawColor(winnerColor: UIColor) {
        let width = WKInterfaceDevice.currentDevice().screenBounds.width
        let height = WKInterfaceDevice.currentDevice().screenBounds.height
        
        // Create a graphics context
        let size = CGSizeMake(width, height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        winnerColor.setStroke()
        winnerColor.setFill()
        
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
        percentArray = []
        namesArray = []
        print(userInfo)
        for result in userInfo["results"]! as! [AnyObject] {
            percentArray.append(result["exact"] as! Double)
            namesArray.append(result["name"] as! String)
        }
        let maxPercent = percentArray.maxElement()
        let maxPercentIndex = percentArray.indexOf(maxPercent!)
        let winnerName = namesArray[maxPercentIndex!]
        
        if winnerName == Parties.GRUE.rawValue || winnerName == Parties.VdB.rawValue {
            winnerColor = UIColor.init(red: 120/255, green: 175/255, blue: 53/255, alpha: 1.0)
        }
        if winnerName == Parties.SPOE.rawValue || winnerName == Parties.Hundstorfer.rawValue {
            winnerColor = UIColor.init(red: 243/255, green: 17/255, blue: 55/255, alpha: 1.0)
        }
        if winnerName == Parties.OEVP.rawValue || winnerName == Parties.Khol.rawValue {
            winnerColor = UIColor.init(red: 54/255, green: 54/255, blue: 54/255, alpha: 1.0)
        }
        if winnerName == Parties.NEOS.rawValue {
            winnerColor = UIColor.init(red: 234/255, green: 61/255, blue: 136/255, alpha: 1.0)
        }
        if winnerName == Parties.FRANK.rawValue {
            winnerColor = UIColor.init(red: 248/255, green: 227/255, blue: 35/255, alpha: 1.0)
        }
        if winnerName == Parties.Griss.rawValue {
            winnerColor = UIColor.init(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0)
        }
        if winnerName == Parties.Lugner.rawValue {
            winnerColor = UIColor.init(red: 119/255, green: 6/255, blue: 140/255, alpha: 1.0)
        }
        if winnerName == Parties.FPOE.rawValue || winnerName == Parties.Hofer.rawValue {
            winnerColor = UIColor.init(red: 14/255, green: 66/255, blue: 142/255, alpha: 1.0)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let name = userInfo["name"] else {
                return
            }
            self.locationNameLabel.setText("\(name)")
            self.partyNameLabel.setText("\(winnerName)")
            self.drawColor(self.winnerColor!)
        }
    }
    
    
    
    //    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    //        dispatch_async(dispatch_get_main_queue()) {
    //            guard let name = applicationContext["name"] else {
    //                return
    //            }
    //            self.locationNameLabel.setText("\(name)")
    //        }
    //    }
    
}
