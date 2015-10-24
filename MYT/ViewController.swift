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

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, MKMapViewDelegate{
    
    @IBOutlet var mapView:MKMapView? = MKMapView()

    @IBOutlet weak var buttonNav:UIButton? = UIButton()
    @IBOutlet weak var buttonStart:UIButton? = UIButton()
    @IBOutlet weak var buttonMenu:UIButton? = UIButton()
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var mapStyleSwitch: UISegmentedControl!
    @IBOutlet weak var mainButtonContainer: UIView!
    @IBOutlet weak var mainButtonTrackContainer: UIView!
    @IBOutlet weak var mainButtonStopContainer: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    let locationTracker = LocationTracker(threshold:3)
    var lastUserLocation:CLLocation = CLLocation()
    var rootGPX = GPXRoot(creator: "Sample GPX")
    var isTracking = false
    var totalDistance:Int = 0
    var timeString:NSString = NSString()
    var startTracikngTime:NSDate = NSDate()
    var timeTrackingTimer:NSTimer = NSTimer()
    
    var lastUserRegion:MKCoordinateRegion = MKCoordinateRegion()
    
    // Line
    var polyline:MKPolyline = MKPolyline ()
    var arrayOfPoints = [CLLocationCoordinate2D]()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.mapView?.delegate = self
        
        let cornerRadius:CGFloat = 5.0
        
        buttonNav?.layer.cornerRadius = cornerRadius
        buttonMenu?.layer.cornerRadius = cornerRadius
        
        buttonNav?.clipsToBounds = true;
        buttonMenu?.clipsToBounds = true;
        
        mainButtonContainer.layer.cornerRadius = cornerRadius
        
        mapStyleSwitch.layer.cornerRadius = cornerRadius
        
        locationTracker.addLocationChangeObserver { (result) -> () in
            switch result {
            case .Success(let location):
                self.updateUserLocationVisually(location)
            case .Failure(let reason):
                println("Some shit happened")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        addBlurToView(viewBottom,viewToBlurr: buttonMenu!)
        addBlurToView(viewBottom,viewToBlurr: buttonNav!)
    }
    
    func addBlurToView(rootView:UIView, viewToBlurr:UIView) {
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
        
        visualEffectView.frame = viewToBlurr.frame;
        
        visualEffectView.layer.cornerRadius = viewToBlurr.layer.cornerRadius;
        visualEffectView.clipsToBounds = viewToBlurr.clipsToBounds;
        
        viewBottom.insertSubview(visualEffectView, belowSubview: viewToBlurr)
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
        
        var latitudinalMeters = 300.0
        var longitudinalMeters = 300.0
        lastUserRegion = MKCoordinateRegionMakeWithDistance(ctrpoint, latitudinalMeters, longitudinalMeters)
       
        
        // Create Pin
        var addAnnotation:MKPointAnnotation = MKPointAnnotation()
        addAnnotation.coordinate = ctrpoint
        
        // Remove all point
        if(self.mapView?.annotations.count > 0) {
            self.mapView?.removeAnnotations(self.mapView?.annotations)
        }
        
        // Add new Annotation
        self.mapView?.addAnnotation(addAnnotation)
        self.mapView?.setRegion(lastUserRegion, animated: true)
    
        
        if(!isTracking) {
            return;
        }
        
        // Distance
        var newUserLocation:CLLocation = CLLocation(latitude: ctrpoint.latitude,longitude: ctrpoint.longitude)
        var meters:CLLocationDistance = newUserLocation.distanceFromLocation(lastUserLocation)
        var kilometers:CLLocationDistance = meters / 1000.0;
        
        lastUserLocation = newUserLocation;
        
        // Distance filter
        if(Double(meters) >= 100) {
            return;
        }
        
        totalDistance += Int(meters)
        distanceLabel.text = convertMetersToKMString(totalDistance)
        
//        if(totalDistance == 0) {
//            distanceLabel.text = String(format:"%.f meters",Double(meters))
//            let a:Int? = distanceLabel.text?.toInt()
//            let myNumber = NSNumberFormatter().numberFromString(distanceLabel.text!)
//            totalDistance += Int(meters)
//        } else if (totalDistance != 0) {
//            totalDistance += Int(meters)
//            distanceLabel.text = String(format:"%i meters",totalDistance)
//        }
        
        // Save GPX
        addPointToCurrentGPXFrom(CGFloat(coordinate.latitude), longitude:CGFloat(coordinate.longitude))
        
        // Save to Lines
        arrayOfPoints.append(ctrpoint)
        
        //Draw Line
        self.drawLineOnMap()
    }
    
    func convertMetersToKMString(meters: Int) -> String  {
        
        var returnString:String = "";
        
        if (meters > 1000) {
            returnString = String(format:"%i km %i meters",meters/1000, meters%1000)
        } else {
            returnString = String(format:"%i meters", meters)
        }
        
        return returnString;
    }
    
    // Custom annotation
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("customAnnotation")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "MapAnnotation")
        
        return annotationView
        
    }
    
    func drawLineOnMap() {
        // Remove old polyline if one exists
        self.mapView?.removeOverlay(self.polyline)
//        rootGPX
        let pointer: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(arrayOfPoints)
        
        self.polyline = MKPolyline(coordinates: pointer, count: arrayOfPoints.count)
        self.mapView?.addOverlay(self.polyline)
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
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        let timestamp = dateFormatter.stringFromDate(NSDate())
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
            stopTrackingNewMovment()
        } else {
            startTrackingNewMovment()
        }
    }
    
    @IBAction func stopButtonPress(sender: AnyObject) {
        stopTrackingNewMovment();
    }
    
    @IBAction func switchValueChage(sender: AnyObject) {
        
        var segmentControl:UISegmentedControl = sender as! UISegmentedControl

        if(segmentControl.selectedSegmentIndex == 1) {
            self.mapView?.mapType = MKMapType.Hybrid
             NSUserDefaults.standardUserDefaults().setBool(false, forKey: "MAP_VIEW_TYPE_IS_STANDARD")
        } else {
            self.mapView?.mapType = MKMapType.Standard
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "MAP_VIEW_TYPE_IS_STANDARD")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func startTrackingNewMovment() {
        isTracking = true
        
        mainButtonTrackContainer.hidden = true;
        mainButtonStopContainer.hidden = false;
        
        self.mapView?.removeOverlay(self.polyline)
        arrayOfPoints.removeAll(keepCapacity: false)
        
        startTracikngTime = NSDate();
        timeTrackingTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimeLabel"), userInfo: nil, repeats: true);
        
        createNewGPXFile();
        locationTracker.resumeLocationUpdate();
    }
    
    func stopTrackingNewMovment() {
        
        isTracking = false
        
        mainButtonTrackContainer.hidden = false;
        mainButtonStopContainer.hidden = true;
        timeTrackingTimer.invalidate();
        
        // Save stuff
        rootGPX.metadata = GPXMetadata();
        rootGPX.metadata.name = timeString as! String;
        rootGPX.metadata.keyword = distanceLabel.text
        
        saveGPXToDrive(rootGPX)
        
        lastUserLocation = CLLocation()
        
        // Remove stuff
        durationLabel.text = "00:00:00";
        distanceLabel.text = "0 meters";
        totalDistance = 0;
       
    }
    
    func updateTimeLabel() {
        
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(NSCalendarUnit.SecondCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.HourCalendarUnit, fromDate: startTracikngTime, toDate: NSDate(), options: nil)
        
        var hours = datecomponenets.hour >= 60 ? 0 : datecomponenets.hour;
        var minutes = datecomponenets.minute >= 60 ? 0 : datecomponenets.minute;
        var seconds = datecomponenets.second >= 60 ? 0 : datecomponenets.second;
        
        timeString = NSString(format:"%02d:%02d:%02d", hours, minutes, seconds)
        
        durationLabel.text = timeString as! String;
        
        println(timeString)
    }
    
    // Show stuff
    
    @IBAction func onCenterButtonPress(sender: AnyObject) {
        self.mapView?.setRegion(lastUserRegion, animated: true)
    }
    
    
    @IBAction func showButtonPresse(sender: AnyObject) {
        self.performSegueWithIdentifier("MYT_Segue_DataShowController", sender: nil)
    }
    
    // Map View Delegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return nil
    }
}
