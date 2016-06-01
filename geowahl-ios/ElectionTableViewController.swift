//
//  ElectionTableViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 30.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit
import WatchConnectivity

class ElectionTableViewController: UITableViewController, WCSessionDelegate {
    
    var session: WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.rowHeight = 64
        
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
    @IBAction func pushButton() {
        let applicationDict = ["key": "value"]
        //        do {
        //            try session?.updateApplicationContext(applicationDict)
        //            print("send")
        //        } catch {
        //            print("error")
        //        }
        session.transferUserInfo(applicationDict)
    }
    var elections: [String] = ["Wien", "NÖ", "OÖ", "Salzburg"]
    
    //Elections
    var electionsnew = [
        "1": [
            "id": 1,
            "slug": "Gemeinderatswahlen",
            "name": "Gemeinderatswahlen"
        ],
        "2": [
            "id": 2,
            "slug": "Bundespräsidentenwahl",
            "name": "Bundespräsidentenwahl"
        ]
        
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
        
        cell.textLabel?.text = elections[indexPath.row]
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStates" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let states = elections[indexPath.row]
                (segue.destinationViewController as! StateTableViewController).statesName = states
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
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "showStates" {
    //            if let indexPath = tableView.indexPathForSelectedRow {
    //
    //            }
    //        }
    //    }
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "showDaily" {
    //            if let indexPath = tableView.indexPathForSelectedRow {
    //                let dailyWeather = weeklyWeather[indexPath.row]
    //
    //                (segue.destinationViewController as! ViewController).dailyWeather = dailyWeather
    //            }
    //        }
    //    }
    
}
