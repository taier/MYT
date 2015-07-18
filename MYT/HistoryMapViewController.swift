//
//  HistoryMapViewController.swift
//  MYT
//
//  Created by Denis Kaibagarov on 6/22/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import UIKit
import MapKit

class HistoryMapViewController: UIViewController {
    
    @IBOutlet weak var mapViewHistory: MKMapView!
    
    var _selectedFileName: String?
    
    // Setter TODO: Make cooler!
    func setSelectedName(name:String) -> Void {
        _selectedFileName = name;
    }
    
    override func viewDidLoad() {
        mapViewHistory.layer.cornerRadius = 4.0
        
        var rootFromDrive:GPXRoot = self.readGPXRootFromDrive()
        
        for track in rootFromDrive.tracks {
            self.plotPlacemarkOnMap(track as! GPXTrack)
        }
    }
    
    func readGPXRootFromDrive() -> GPXRoot {
        
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        var fileurl =  dir.URLByAppendingPathComponent("GPXFiles")
        fileurl = fileurl.URLByAppendingPathComponent(_selectedFileName!)
        
        var gpxString = String(contentsOfFile: fileurl.path!, encoding: NSUTF8StringEncoding, error: nil)
        var gpx = GPXParser.parseGPXWithString(gpxString);
        
        return gpx;

    }
    
    //TODO: Same as in ViewController. Make one?
    func plotPlacemarkOnMap(gpxTrack:GPXTrack) {
        
        if (gpxTrack.tracksegments.count == 0) {
            return; // Don't have data to show :(
        }
        
        let gpxTrackSegments = gpxTrack.tracksegments.first as! GPXTrackSegment
        let gpxTrackPoint = gpxTrackSegments.trackpoints.first as! GPXTrackPoint
        
        // Create iOS Location from raw data
        var ctrpoint:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        var latitude:CLLocationDegrees = CLLocationDegrees(gpxTrackPoint.latitude)
        var longitude:CLLocationDegrees = CLLocationDegrees(gpxTrackPoint.longitude)
        
        ctrpoint.latitude = latitude
        ctrpoint.longitude = longitude
        
        // Set MapView zoom
        var latDelta:CLLocationDegrees = 0.1
        var longDelta:CLLocationDegrees = 0.1
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var latitudinalMeters = 100.0
        var longitudinalMeters = 100.0
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(ctrpoint, latitudinalMeters, longitudinalMeters)
        
        self.mapViewHistory?.setRegion(theRegion, animated: true)
        
        // Create Pin
        var addAnnotation:MKPointAnnotation = MKPointAnnotation()
        addAnnotation.coordinate = ctrpoint
        
        // Just showing start position, don't do anything with it yet
        self.mapViewHistory?.addAnnotation(addAnnotation)
    }
    
    //***** Outlet Actions
    
    @IBAction func onBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
}
