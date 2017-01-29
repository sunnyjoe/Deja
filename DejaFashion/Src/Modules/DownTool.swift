//
//  DownTool.swift
//  DejaFashion
//
//  Created by jiao qing on 9/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//
import SSZipArchive

class DownTool: NSObject {
    
/**
     -(NSString *)patchPathOfVersion: (NSString *)version {
     return [self.dir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.js", version]];
     }
     
     NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     self.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
     self.dir = [doc stringByAppendingPathComponent:@"jspatch"];
     if (![[NSFileManager defaultManager] fileExistsAtPath:self.dir])
     [[NSFileManager defaultManager] createDirectoryAtPath:self.dir withIntermediateDirectories:NO attributes:nil error:nil];
     
     */

    //sync

    static var cachedFileMap = [String: String]()
    
    class func download(urlStrings : [String], clothesId : String, bodyShapeId : String) -> Bool{
        
        for urlString in urlStrings {
            let url = NSURL(string: urlString)
            if url == nil{
                return false
            }
            if let _ = cachedFileMap[urlString] {
                continue
            }
            let data = try? NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: url!), returningResponse: nil)
            let doc = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).first
            let file = doc! + "/\(clothesId)_\(bodyShapeId).zip"
            let dir = doc! + "/\(clothesId)_\(bodyShapeId)/"
            if let d = data {
                let _ = try? d.writeToFile(file, options: .DataWritingAtomic)
            }else {
                return false
            }
            
            let result = SSZipArchive.unzipFileAtPath(file, toDestination: dir)
            
            if result {
                cachedFileMap[urlString] = file
            }else {
                return false
            }
            
        }
        return true
    }
    
    class func queryByString(clothesId : String, tryonableClotheId: String, bodyShapeId : String, partId : String) -> String? {
        let doc = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).first
        let dir = doc! + "/\(clothesId)_\(bodyShapeId)/"
        let file = dir + "output/\(tryonableClotheId)/\(tryonableClotheId)_\(bodyShapeId)/\(tryonableClotheId)_\(bodyShapeId)_\(partId).txt"
        let stringTxt = try? String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
        return stringTxt
    }
}
