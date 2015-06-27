//
//  GPXFileManager.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation

//GPX File extension
let kFileExt = "gpx"

//
// Class to handle actions with gpx files (save, delete, etc..)
//
//
class GPXFileManager : NSObject {
    
    class var gpxFilesFolder: String {
        get {
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            return documentsDirectory
        }
    }
    //Gets the list of .gpx files in Documents directory
    class var fileList: [AnyObject]  {
        get {
            let defaultManager = NSFileManager.defaultManager()
            var filePathsArray : NSArray = try! defaultManager.subpathsOfDirectoryAtPath(self.gpxFilesFolder)
            let predicate : NSPredicate = NSPredicate(format: "SELF EndsWith '.\(kFileExt)'")
            filePathsArray = filePathsArray.filteredArrayUsingPredicate(predicate)
            
            //We want latest files created on top. It seems we have to reverse the path
            filePathsArray = filePathsArray.reverseObjectEnumerator().allObjects
            return filePathsArray as [AnyObject]
        }
    }
    //
    // @param filename gpx filename without extension
    class func pathForFilename(filename: String) -> String {
        let documentsPath = self.gpxFilesFolder
        var ext = ".\(kFileExt)" // add dot to file extension
        //check if extension is already there
        let tmpExt : String = filename.pathExtension
        print("extension: \(tmpExt)")
        if kFileExt ==  tmpExt  {
            ext = ""
        }
        let fullPath = documentsPath.stringByAppendingPathComponent("\(filename)\(ext)")
        return fullPath
    }
    class func fileExists(filename: String) -> Bool {
        let filePath = self.pathForFilename(filename)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath);
    }
    
    class func save(filename: String, gpxContents : String) {
        //check if name exists
        let finalFilePath: String = self.pathForFilename(filename)
        //save file
        print("Saving file at path: \(finalFilePath)")
        // write gpx to file
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.writeToFile(finalFilePath, atomically: true, encoding: NSUTF8StringEncoding)
            saved = true
        } catch var error as NSError {
            writeError = error
            saved = false
        }
        if !saved {
            if let error = writeError {
                print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }
    }
    
    class func removeFile(filename: String) {
        let filepath: String = self.pathForFilename(filename)
        let defaultManager = NSFileManager.defaultManager()
        var error: NSError?
        let deleted: Bool
        do {
            try defaultManager.removeItemAtPath(filepath)
            deleted = true
        } catch var error1 as NSError {
            error = error1
            deleted = false
        }
        if !deleted {
             if let e = error {
                print("[ERROR] GPXFileManager:removeFile: \(filepath) : \(e.localizedDescription)")
            }
        }
    }
    
}