//
//  DataShowController.swift
//  MYT
//
//  Created by Denis Kaibagarov on 6/22/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import UIKit
import MessageUI
import iAd

class DataShowController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, ADBannerViewDelegate {
    
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var iadBanner: ADBannerView!
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
        self.setupiAd()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = self.mainTableView.indexPathForSelectedRow()
        if (indexPath != nil) {
            self.mainTableView.deselectRowAtIndexPath(indexPath!, animated: false)
        }
    }
    
    //Alert handlers
    
    func feedbackHandler(alert: UIAlertAction!) {
       
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("MYT Support")
            mailComposer.setMessageBody("Hey, my question is:", isHTML: false)
            let recipents:NSArray = ["ask@sudo.mobi"]
            mailComposer.setToRecipients(recipents as [AnyObject])
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Sorry",
                message:"Please, setup mail on device before sending reports.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func shareHandler(alert: UIAlertAction!) {
        NSLog("Share")
        let objectsToShare = ["Hey! Check out that awesome app! Map My Travel - Your Personal Travel Sharing! https://goo.gl/BiJHSr"]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        //New Excluded Activities Code
//        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func rateHandler(alert: UIAlertAction!) {
        NSLog("Rate")
        UIApplication.sharedApplication().openURL(NSURL(string:"https://itunes.apple.com/us/app/map-my-travel-your-personal/id1041673662?ls=1&mt=8")!)
    }
    
    // Table view stuff
    
    func setupData() {
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        var fileurl =  dir.URLByAppendingPathComponent("GPXFiles")
        
        if (NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) == false) {
            return; // Crash free
        }
        
        let enumerator:NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(fileurl.path!)!
        
        for dataEntity in enumerator.allObjects.reverse() {
            arrayData.addObject(dataEntity as! String)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell_ : HistoryTableViewCell? = tableView.dequeueReusableCellWithIdentifier("SHOW_CELL") as? HistoryTableViewCell
        
        let fileName = arrayData[indexPath.row] as? String;
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        let dateString = fileName!.stringByDeletingPathExtension
        
        let date = formatter.dateFromString(dateString)
       
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        cell_!.labelTopText!.text = formatter.stringFromDate(date!)
        
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
    
    // ****** Mail Composer Delegates
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func setupiAd() {
        iadBanner.delegate = self
        iadBanner.hidden = true
    }
    
    // ****** iAD Banner Delegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        iadBanner.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        iadBanner.hidden = true
    }
}
