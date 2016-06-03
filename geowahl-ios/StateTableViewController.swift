//
//  StateTableViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 31.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit

class StateTableViewController: UITableViewController {

    var index: Int?
    var indexPathOfElection: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 64
        
        if let indexPath = index {
            indexPathOfElection = indexPath
        } else {
            print("No data")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
                        if let electionStates = election["states"]!![indexPath.row]["slug"] {
                            slugsDict = [
                                "electionSlug" : (election["slug"])! as! String,
                                "statesSlug" : electionStates! as! String
                            ]
                            (segue.destinationViewController as! DistrictsTableViewController).data = slugsDict
                        }
                    }
                }
            }
        }
    }
    
}
