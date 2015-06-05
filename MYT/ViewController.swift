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
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationTracker = LocationTracker(threshold:1.0)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        
        // Show on label
        self.locationLabel.text = "Location: \(locationString)"
        
        // Save on Drive
        saveCoodinatesToDrive(locationString)
        
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
        
        self.mapView?.addAnnotation(addAnnotation);
        
    }
    
    func plotPlacemarkOnMap(placemark:CLPlacemark?) {

        
        var latDelta:CLLocationDegrees = 0.1
        var longDelta:CLLocationDegrees = 0.1
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var latitudinalMeters = 100.0
        var longitudinalMeters = 100.0
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(placemark!.location.coordinate, latitudinalMeters, longitudinalMeters)
        
        self.mapView?.setRegion(theRegion, animated: true)
        
        self.mapView?.addAnnotation(MKPlacemark(placemark: placemark))
    }
    
    func saveCoodinatesToDrive(coordinatesString : String) -> Void {
        
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        let fileurl =  dir.URLByAppendingPathComponent("log.txt")
    
        let data = coordinatesString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
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
    
    @IBAction func sendMail(sender: AnyObject) {
        
        var file = "log.txt";
        
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String] {
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingPathComponent(file);
            
            //reading
            let textToSend = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
            
            var picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            picker.setSubject("My waypoints")
            picker.setMessageBody(textToSend, isHTML: true)
            
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
