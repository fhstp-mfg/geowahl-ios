//
//  DistrictsTableViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 03.06.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

class DistrictsTableViewController: UITableViewController, WCSessionDelegate {
    
    var session: WCSession!
    var data : [String : String]? = nil
    var postEndpoint: String?
    var electionSlug: String?
    var stateSlug: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 64
        if let dataSlugs = data {
            guard let electionSlug = dataSlugs["electionSlug"] else {
                return
            }
            guard let stateSlug = dataSlugs["statesSlug"] else {
                return
            }
            guard let stateName = dataSlugs["statesName"] else {
                return
            }
            self.title = stateName
            self.electionSlug = electionSlug
            self.stateSlug = stateSlug
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
        
        getJson(slugs: "/\(self.electionSlug!)/\(self.stateSlug!)/districts")
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
                        districtsDict = jsonDictionary
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if districtsDict == nil {
            return 0
        } else {
            if let district = districtsDict!["districts"] {
                return district.count
            } else {
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        session.transferUserInfo(districtsDict!["districts"]![indexPath.row]! as! [String : AnyObject])
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("districtsCell", forIndexPath: indexPath)
        //print(districtsDict!["districts"]![indexPath.row]["name"])
        if let electionsDistricts = districtsDict!["districts"] {
            if let electionsDistrictName = electionsDistricts[indexPath.row]["name"] {
                cell.textLabel?.text = electionsDistrictName as? String
            }
        } else {
            
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destinationViewController as! ViewController).data = districtsDict!["districts"]![indexPath.row]!
            }
        }
    }
}
