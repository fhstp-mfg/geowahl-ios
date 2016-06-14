//
//  StateTableViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 31.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

class StateTableViewController: UITableViewController, CLLocationManagerDelegate, WCSessionDelegate {
    
    var index: Int?
    var indexPathOfElection: Int?
    var session : WCSession!
    var locationManager = CLLocationManager()
    var isGettingLocation : Bool = false
    var postEndpoint: String?
    var locationDict: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 64
        if let indexPath = index {
            indexPathOfElection = indexPath
            self.title = dict!["elections"]![indexPathOfElection!]["name"] as? String
        } else {
            print("No data")
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getLocation(sender: AnyObject) {
        if !isGettingLocation {
            self.locationManager.requestAlwaysAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            } else {
                print("Need to Enable Location")
            }
            self.locationManager.startUpdatingLocation()
            isGettingLocation = true
        } else {
            self.locationManager.stopUpdatingLocation()
            isGettingLocation = false
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func getJson(slugs slugs: String, lat: CLLocationDegrees? = nil, long: CLLocationDegrees? = nil ) {
        let baseURL: String = "http://geowahl.suits.at"
        if let lat = lat, let long = long {
            postEndpoint = "\(baseURL)\(slugs)/\(lat),\(long)"
        } else {
            postEndpoint = "\(baseURL)\("48.2229566,16.456883")"
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
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.locationDict = jsonDictionary
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
        print("Is updating location")
        getJson(slugs: "/\(dict!["elections"]![indexPathOfElection!]["slug"]!!)", lat: lat, long: long)
        if let location = locationDict {
            print(location["district"]! as! [String : AnyObject])
            session.transferUserInfo(location["district"]! as! [String : AnyObject])
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: "  + error.localizedDescription)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dict == nil {
            return 0
        } else {
            if let electionsArray = dict!["elections"] {
                if let election = electionsArray[indexPathOfElection!] {
                    if let electionsStates = election["states"] {
                        return (electionsStates?.count)!
                    }
                }
            }
            else {
                return 0
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stateCell", forIndexPath: indexPath)
        if let electionsArray = dict!["elections"] {
            if let election = electionsArray[indexPathOfElection!]{
                if let electionStates = election["states"]!![indexPath.row]["name"] {
                    cell.textLabel?.text = electionStates as? String
                }
            }
            
        } else {
            
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var slugsDict : [String : String]?
        if segue.identifier == "showDistricts" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let electionsArray = dict!["elections"] {
                    if let election = electionsArray[indexPathOfElection!] {
                        if let electionStates = election["states"]!![indexPath.row]["slug"], let statesName = election["states"]!![indexPath.row]["name"] {
                            slugsDict = [
                                "electionSlug" : (election["slug"])! as! String,
                                "statesSlug" : electionStates! as! String,
                                "statesName" : statesName! as! String
                            ]
                            if isGettingLocation {
                                self.locationManager.stopUpdatingLocation()
                                isGettingLocation = false
                            }
                            (segue.destinationViewController as! DistrictsTableViewController).data = slugsDict
                        }
                    }
                }
            }
        }
    }
    
}
