//
//  ElectionTableViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 30.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreLocation

class ElectionTableViewController: UITableViewController, WCSessionDelegate, CLLocationManagerDelegate {
    
    var session: WCSession!
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.rowHeight = 64
        
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        } else {
            print("Need to Enable Location")
        }
        

        if WCSession.isSupported() {
            print("Session is supported")
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            if session.paired {
                print("Watch is paired")
            } else {
                print("Watch is not paired")
            }
            if session.reachable {
                print("Phone is reachable")
            } else {
                print("Phone is not reachable")
            }
        } else {
            print("Session is not supported")
        }
        
        let postEndpoint: String = "http://geowahl.suits.at/elections"
        let url = NSURL(string: postEndpoint)!
        let sessionJSON = NSURLSession.sharedSession()
        sessionJSON.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else {
                print("Not a 200 response")
                return
            }
            // Read the JSON
            do {
                if let ipString = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                }
            } catch let error as NSError{
                print("Error: \(error)")
                return
            }
        }).resume()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        //print("Data: \((lat, long))")
        
        let geocoder = CLGeocoder()
        let locationIn = CLLocation(latitude: lat, longitude: long)
        geocoder.reverseGeocodeLocation(locationIn) {
            (placemarks, error) -> Void in
            let placeArray = placemarks as [CLPlacemark]!
            var placeMark: CLPlacemark!
            placeMark = placeArray?.first
            
            //print(placeMark.addressDictionary)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: "  + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Elections

    var elections = [
        ["name" : "Gemeinderatswahlen"],
        ["name" : "Bundespräsidentenwahl"]
    ]
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return elections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("stateCell", forIndexPath: indexPath)
//        if indexPath.row == 0 {
//            cell.backgroundColor = UIColor.blueColor()
//        }
        let election = elections[indexPath.row]
        cell.textLabel?.text =  election["name"]!

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(elections[indexPath.row])
        let election = elections[indexPath.row]
        session.transferUserInfo(["key": election["name"]!])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStates" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let election = elections[indexPath.row]
                (segue.destinationViewController as! StateTableViewController).statesName = election["name"]
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
