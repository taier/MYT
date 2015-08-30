//
//  HistoryMapViewController.swift
//  MYT
//
//  Created by Denis Kaibagarov on 6/22/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class HistoryMapViewController: UIViewController, MKMapViewDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mapViewHistory: MKMapView!
    
    var maxLatitude:CGFloat = 0;
    var minLatitude:CGFloat = 9999;
    
    var maxLogitude:CGFloat = 0;
    var minLogitude:CGFloat = 9999;
    
    var middlePoint:Int = 0;
    
    var middleCtrpoint:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var polyline:MKPolyline = MKPolyline ()
    var arrayOfPoints = [CLLocationCoordinate2D]()
    
    var _selectedFileName: String?
    
    // Setter TODO: Make cooler!
    func setSelectedName(name:String) -> Void {
        _selectedFileName = name;
    }
    
    override func viewDidLoad() {
        mapViewHistory.layer.cornerRadius = 4.0
        
        var rootFromDrive:GPXRoot = self.readGPXRootFromDrive()
        
        self.mapViewHistory.delegate = self;
        
        var middlePoint = rootFromDrive.tracks.count/2;
        
        var i:Int = 0;
        for track in rootFromDrive.tracks {
            i++;
            self.plotPlacemarkOnMap(track as! GPXTrack, needToSaveMiddlePoint: middlePoint == i ? true : false)
        }
        
        // Set Map Zoom
        
        var latitudinalMeters = 100.0
        var longitudinalMeters = 100.0
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(middleCtrpoint, latitudinalMeters, longitudinalMeters)
        
        self.mapViewHistory?.setRegion(theRegion, animated: true)
        
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
    func plotPlacemarkOnMap(gpxTrack:GPXTrack, needToSaveMiddlePoint:Bool) {
        
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
        
        if (needToSaveMiddlePoint) {
            self.middleCtrpoint = ctrpoint;
        }
        
        // For Region
        self.maxLatitude = gpxTrackPoint.latitude >= self.maxLatitude ? gpxTrackPoint.latitude : self.maxLatitude;
        self.maxLogitude = gpxTrackPoint.longitude >= self.maxLogitude ? gpxTrackPoint.longitude : self.maxLogitude;
        
        self.minLatitude =  gpxTrackPoint.latitude <= self.minLatitude ? gpxTrackPoint.latitude : self.minLatitude;
        self.minLogitude = gpxTrackPoint.longitude <= self.minLogitude ? gpxTrackPoint.longitude : self.minLogitude;
        
        // Save to Lines
        arrayOfPoints.append(ctrpoint)
        
//        // Set MapView zoom
//        var latDelta:CLLocationDegrees = 0.1
//        var longDelta:CLLocationDegrees = 0.1
//        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
//        
//        var latitudinalMeters = 100.0
//        var longitudinalMeters = 100.0
//        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(ctrpoint, latitudinalMeters, longitudinalMeters)
//        
//        self.mapViewHistory?.setRegion(theRegion, animated: true)
//        
//        // Create Pin
//        var addAnnotation:MKPointAnnotation = MKPointAnnotation()
//        addAnnotation.coordinate = ctrpoint
        
        // Just showing start position, don't do anything with it yet
//        self.mapViewHistory?.addAnnotation(addAnnotation)
        
        //Draw Line
        self.drawLineOnMap()

    }
    
    //***** Outlet Actions
    
    @IBAction func onBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    // ***** Draw stuff on Map
    
    func drawLineOnMap() {
        // Remove old polyline if one exists
        self.mapViewHistory?.removeOverlay(self.polyline)
        //        rootGPX
        let pointer: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(arrayOfPoints)
        
        self.polyline = MKPolyline(coordinates: pointer, count: arrayOfPoints.count)
        self.mapViewHistory?.addOverlay(self.polyline)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return nil
    }
    
    @IBAction func onShareButtonPress(sender: AnyObject) {
        self.sendLocationImage();
    }
    
    
    func sendLocationImage() -> Void {
        //Create the UIImage
        UIGraphicsBeginImageContext(self.mapViewHistory.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        let fileData = UIImageJPEGRepresentation(image, 1.0);
        
        //Set the subject and message of the email
        mailComposer.setSubject("Have you heard abut MYT")
        mailComposer.setMessageBody("Here is your locations!", isHTML: false)
        
        mailComposer.addAttachmentData(fileData, mimeType: "image/png", fileName: "LocatonImage.png");
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    // ****** Mail Composer Delegates
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
