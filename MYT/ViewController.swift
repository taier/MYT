//
//  ViewController.swift
//  MYT
//
//  Created by Deniss Kaibagarovs on 6/2/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var mapView:MKMapView? = MKMapView()

    @IBOutlet weak var buttonNav:UIButton? = UIButton()
    @IBOutlet weak var buttonStart:UIButton? = UIButton()
    @IBOutlet weak var buttonMenu:UIButton? = UIButton()
    
    let locationTracker = LocationTracker(threshold:1.0)
    var rootGPX = GPXRoot(creator: "Sample GPX")
    var isTracking = false;
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let cornerRadius:CGFloat = 4.0
        
        buttonNav?.layer.cornerRadius = cornerRadius
        buttonStart?.layer.cornerRadius = cornerRadius
        buttonMenu?.layer.cornerRadius = cornerRadius
        
        locationTracker.addLocationChangeObserver { (result) -> () in
            switch result {
            case .Success(let location):
                self.updateUserLocationVisually(location)
            case .Failure(let reason):
                println("Some shit happened")
            }
        }
    }
    
    func updateUserLocationVisually(newLocation: LocationTracker.Location) -> Void {
        
        let coordinate = newLocation.physical.coordinate
        let locationString = "\(coordinate.latitude), \(coordinate.longitude)"
        
        
        // Create iOS Location from raw data
        var ctrpoint:CLLocationCoordinate2D = CLLocationCoordinate2D()
        ctrpoint.latitude = coordinate.latitude
        ctrpoint.longitude = coordinate.longitude
        
        // Set MapView zoom
        var latDelta:CLLocationDegrees = 0.1
        var longDelta:CLLocationDegrees = 0.1
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var latitudinalMeters = 100.0
        var longitudinalMeters = 100.0
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(ctrpoint, latitudinalMeters, longitudinalMeters)
        
        self.mapView?.setRegion(theRegion, animated: true)
        
        // Create Pin
        var addAnnotation:MKPointAnnotation = MKPointAnnotation()
        addAnnotation.coordinate = ctrpoint
        
        // Just showing start position, don't do anything with it yet
        self.mapView?.addAnnotation(addAnnotation)
        
        if(self.mapView?.annotations.count == 1) {
            locationTracker.pauseLocationUpdate();
            return;
        }
        
        // Save GPX
        addPointToCurrentGPXFrom(CGFloat(coordinate.latitude), longitude:CGFloat(coordinate.longitude))
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // GPX stuff
    func createNewGPXFile() {
        rootGPX = nil;
        rootGPX = GPXRoot(creator: "My Movements")
        rootGPX.newTrack()
    }
    
    func addPointToCurrentGPXFrom(latitude: CGFloat, longitude: CGFloat) -> Void {
        
        var track = rootGPX.newTrack()
        track.newTrackpointWithLatitude(latitude, longitude: longitude)
        
        rootGPX.addTrack(track);
        println("Logging location")
    }
    
    func saveGPXToDrive(gpxToSave: GPXRoot) {
        
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        var fileurl =  dir.URLByAppendingPathComponent("GPXFiles")
        
        // Create directory if needed
        if (NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) == false) {
            NSFileManager.defaultManager().createDirectoryAtPath(fileurl.path!, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        fileurl = fileurl.URLByAppendingPathComponent(timestamp + ".gpx")
        
        let data = rootGPX.gpx().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        if NSFileManager.defaultManager().fileExistsAtPath(fileurl.path!) {
            var err:NSError?
            if let fileHandle = NSFileHandle(forWritingToURL: fileurl, error: &err) {
                fileHandle.seekToEndOfFile()
                fileHandle.writeData(data)
                fileHandle.closeFile()
            }
            else {
                println("Can't open fileHandle \(err)")
            }
        }
        else {
            var err:NSError?
            if !data.writeToURL(fileurl, options: .DataWritingAtomic, error: &err) {
                println("Can't write \(err)")
            }
        }
    }
    
    // Tracking stuff
    @IBAction func trackButtonPress(sender: AnyObject) {
        if (isTracking) {
             // Stop tracking
            sender.setTitle("Track", forState: UIControlState.Normal)
            stopTrackingNewMovment()
        } else {
            // Start tracking
            sender.setTitle("Stop", forState: UIControlState.Normal)
            startTrackingNewMovment()
        }

    }
    
    func startTrackingNewMovment() {
        isTracking = true
        
        createNewGPXFile();
        
        // Resume updates if can
        if(locationTracker.isPaused) {
            locationTracker.resumeLocationUpdate();
        }
    }
    
    func stopTrackingNewMovment() {
        isTracking = false
        
        locationTracker.pauseLocationUpdate()
        
        saveGPXToDrive(rootGPX)
    }
    // Show stuff
    
    @IBAction func showButtonPresse(sender: AnyObject) {
        self.performSegueWithIdentifier("MYT_Segue_DataShowController", sender: nil)
    }
}
