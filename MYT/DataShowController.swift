//
//  DataShowController.swift
//  MYT
//
//  Created by Denis Kaibagarov on 6/22/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import UIKit

class DataShowController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var infoButton: UIBarButtonItem!
    var arrayData = NSMutableArray()
    var _selectedFileName: String?

    //IBActions
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onInfoButtonPress(sender: AnyObject) {
        let alertTitle = "Thank you for downloading MYT"
        let alertMessage = "If you like the app you can leave feedback, tell your friends about it and you can also rate it in the App Store."
        var alert : UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.barButtonItem = self.infoButton
        
        alert.addAction(UIAlertAction(title: "Feedback", style: UIAlertActionStyle.Default, handler: feedbackHandler))
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: shareHandler))
        alert.addAction(UIAlertAction(title: "Rate", style: UIAlertActionStyle.Default, handler: rateHandler))
        
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
    }
    
    //Alert handlers
    
    func feedbackHandler(alert: UIAlertAction!) {
        NSLog("Feedback")
    }

    func shareHandler(alert: UIAlertAction!) {
        NSLog("Share")
    }
    
    func rateHandler(alert: UIAlertAction!) {
        NSLog("Rate")
    }
    
    // Table view stuff
    
    func setupData() {
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        var fileurl =  dir.URLByAppendingPathComponent("GPXFiles")
        
        if (NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) == false) {
            return; // Crash free
        }
        
        let enumerator:NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(fileurl.path!)!
        
        for dataEntity in enumerator.allObjects {
            arrayData.addObject(dataEntity as! String)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell_ : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("SHOW_CELL") as? UITableViewCell
        if(cell_ == nil)
        {
            cell_ = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SHOW_CELL")
        }
        
        cell_!.textLabel!.text = arrayData[indexPath.row] as? String
        
        return cell_!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _selectedFileName = arrayData[indexPath.row] as? String
        self.performSegueWithIdentifier("MYT_Segue_HistoryMapViewController", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MYT_Segue_HistoryMapViewController") {
            var destViewController:HistoryMapViewController = segue.destinationViewController as! HistoryMapViewController
            destViewController.setSelectedName(_selectedFileName!)
        }
    }
}
