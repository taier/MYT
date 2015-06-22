//
//  DataShowController.swift
//  MYT
//
//  Created by Denis Kaibagarov on 6/22/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//


import UIKit

class DataShowController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrayData = NSMutableArray()

    @IBAction func onBackButtonPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onInfoButtonPress(sender: AnyObject) {
        
    }
    
    // Table view stuff
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        var fileurl =  dir.URLByAppendingPathComponent("GPXFiles")
        
         if (NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) == false) {
            return 0; // Crash free
        }
        
        let enumerator:NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(fileurl.path!)!
        
        for dataEntity in enumerator.allObjects {
            arrayData.addObject(dataEntity as! String)
        }
        
        return arrayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell_ : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("SHOW_CELL") as? UITableViewCell
        if(cell_ == nil)
        {
            cell_ = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SHOW_CELL")
        }
        
        cell_!.textLabel!.text = arrayData[indexPath.row] as! String
        
        return cell_!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("MYT_Segue_HistoryMapViewController", sender: nil)
    }

}
