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
    var postEndpoint: String?

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        getJson(slugs: "/elections")
        
    }
    
    func getJson(slugs slugs: String, lat: CLLocationDegrees? = nil, long: CLLocationDegrees? = nil ) {
        let baseURL: String = "http://geowahl.suits.at"
        if let lat = lat, let long = long {
            postEndpoint = "\(baseURL)\(slugs)/\(lat),\(long)"
        } else {
            postEndpoint = "\(baseURL)\(slugs)"
        }
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let sessionJSON: NSURLSession = NSURLSession(configuration: config)
        let url = NSURL(string: postEndpoint!)
        
        let dataTask = sessionJSON.dataTaskWithURL(url!) {
            (let data, let response, let error) in
            if let httpResponse = response as? NSHTTPURLResponse {
                switch (httpResponse.statusCode) {
                case 200:
                    do {
                        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        dict = jsonDictionary
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                        
                    } catch let error {
                        print("JSON Serialization failed. Error: \(error)")
                    }
                default:
                    print("GET request not successful. HTTP statis code: \(httpResponse.statusCode)")
                }
            } else {
                print("Error: Not a valid HTTP response")
            }
        }
        dataTask.resume()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        let geocoder = CLGeocoder()
        let locationIn = CLLocation(latitude: lat, longitude: long)
//        geocoder.reverseGeocodeLocation(locationIn) {
//            (placemarks, error) -> Void in
//            let placeArray = placemarks as [CLPlacemark]!
//            var placeMark: CLPlacemark!
//            placeMark = placeArray?.first
//            
//            //print(placeMark.addressDictionary)
//        }
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dict == nil {
            return 0
        } else {
            if let electionsArray = dict!["elections"] {
                return electionsArray.count
            } else {
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("electionCell", forIndexPath: indexPath)
        if let electionsArray = dict!["elections"] {
            if let electionName = electionsArray[indexPath.row]["name"] as? String {
                cell.textLabel?.text = electionName
            }
        } else {
            
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let election = elections[indexPath.row]
//        session.transferUserInfo(["key": election["name"]!])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStates" {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destinationViewController as! StateTableViewController).index = indexPath.row
            }
        }
    }
}
