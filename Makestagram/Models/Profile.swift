//
//  Profile.swift
//  Makestagram
//
//  Created by Eugene Yurtaev on 26/06/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import ConvenienceKit
import Bond

class Profile {
    
    static var imageCache: NSCacheSwift<String, UIImage>!
    
    var username: Dynamic<String> = Dynamic("")
    var user: PFUser!
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var imageFile: PFFile?
    var once = true
    
    
    init(user: PFUser, imageFile: PFFile?) {
        if once {
            Profile.imageCache = NSCacheSwift<String, UIImage>()
            once = false
        }
        self.username.value = user.username!
        self.user = user
        self.imageFile = imageFile
    }
    
    func retrieveImage() {
        // 1
        if let imageFile = imageFile {
            image.value = Profile.imageCache.objectForKey(self.imageFile!.name)
        } else {
            image.value = nil
        }
//        image.value = Profile.imageCache[self.imageFile!.name]
        
        // if image is not downloaded yet, get it
        if (image.value == nil) {
            
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                    Profile.imageCache[self.imageFile!.name] = image
                }
            }
        }
    }
}