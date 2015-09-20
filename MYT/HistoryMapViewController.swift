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

class HistoryMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapViewHistory: MKMapView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var infoDateLabel: UILabel!
    @IBOutlet weak var infoDurationLabel: UILabel!
    @IBOutlet weak var infoDistanceLabel: UILabel!
    
    @IBOutlet weak var cardContainer: UIView!
    
    
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
        
        // Data
        var rootFromDrive:GPXRoot = self.readGPXRootFromDrive()
        self.mapViewHistory.delegate = self;
        
        var middlePoint = rootFromDrive.tracks.count/2;
        
        var i:Int = 0;
        for track in rootFromDrive.tracks {
            i++;
            self.plotPlacemarkOnMap(track as! GPXTrack, needToSaveMiddlePoint: middlePoint == i ? true : false)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        let dateString = _selectedFileName!.stringByDeletingPathExtension
        let date = formatter.dateFromString(dateString)
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Labels
        infoDateLabel.text = formatter.stringFromDate(date!)
        infoDurationLabel.text = rootFromDrive.metadata.name;
        
        // UI
        cardContainer.layer.cornerRadius = 4.0
        
//        cardContainer.layer.shadowColor = UIColor.blackColor().CGColor
//        cardContainer.layer.shadowRadius = 1.0
        
        // Set Map Zoom
        
        var latitudinalMeters:Double = Double((maxLatitude - minLatitude) * 100000);
        var longitudinalMeters:Double = Double((maxLogitude - minLogitude) * 100000);
        
        var middleX:CLLocationDegrees = CLLocationDegrees((maxLatitude + minLatitude)/2.0);
        var middleY:CLLocationDegrees = CLLocationDegrees((maxLogitude + minLogitude)/2.0);
        
        middleCtrpoint = CLLocationCoordinate2D(latitude: middleX, longitude: middleY);
        
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(middleCtrpoint, latitudinalMeters, longitudinalMeters)
        
        if (theRegion.center.latitude > 500) {
            return;
        }

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
    
    func takeMapSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cardContainer.bounds.size, false, UIScreen.mainScreen().scale)
        
        cardContainer.drawViewHierarchyInRect(cardContainer.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func sendLocationImage() -> Void {
        let image:UIImage = self.takeMapSnapshot();
        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivityTypeCopyToPasteboard,UIActivityTypeAirDrop,UIActivityTypeAddToReadingList,UIActivityTypeAssignToContact,UIActivityTypePostToTencentWeibo,UIActivityTypePostToVimeo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToWeibo]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
