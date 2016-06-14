//
//  ElectionTableViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 30.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit

class ElectionTableViewController: UITableViewController {
    
    var postEndpoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 64
        
        getJson(slugs: "/elections")
        
    }
    
    func getJson(slugs slugs: String) {
        let baseURL: String = "http://geowahl.suits.at"
        postEndpoint = "\(baseURL)\(slugs)"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStates" {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destinationViewController as! StateTableViewController).index = indexPath.row
            }
        }
    }
}
