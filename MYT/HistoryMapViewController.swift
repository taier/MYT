//
//  HistoryMapViewController.swift
//  MYT
//
//  Created by Denis Kaibagarov on 6/22/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import UIKit


class HistoryMapViewController: UIViewController {
    
    @IBOutlet var mapView: GPXMapView!
    
    override func viewDidLoad() {
        
        
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        var fileurl =  dir.URLByAppendingPathComponent("GPXFiles")
        
        if (NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) == false) {
            return // Crash free
        }
        
        let enumerator:NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(fileurl.path!)!
        
        for dataEntity in enumerator.allObjects {
            
            var filePath = fileurl.path! + "/" + (dataEntity as! String)
            var gpxString = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
            var gpx = GPXParser.parseGPXWithString(gpxString);
        
            mapView.importFromGPXRoot(gpx)

            
            return
        }
    }
    @IBAction func onBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
}
