//
//  ProfileViewController.swift
//  Makestagram
//
//  Created by Eugene Yurtaev on 26/06/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import Bond

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var userImage: UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var isPhotoUploading = false
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    var photoTakingHelper: PhotoTakingHelper?
    
    
    var profile: Profile? {
        didSet {
            makeBinding()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        if profile == nil {
            if let curUser = PFUser.currentUser() {
                self.profile = Profile(username: curUser.username!, imageFile: curUser["profilePicture"] as? PFFile)
                self.profile?.retrieveImage()
            }
        }

    }
    

    func makeBinding() {
        if let profile = profile, profilePicture = profilePicture, usernameLabel = usernameLabel {
            profile.image ->> profilePicture
            profile.username ->> usernameLabel.dynText
            profile.retrieveImage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        makeBinding()
        reloadProfilePicture()
        
        if !isCurrentUsersProfile() {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonPressed:")
        }
    }
    
    func reloadProfilePicture() {
        if isCurrentUsersProfile() && isPhotoUploading {
            profilePicture.alpha = 0
            activityView.hidden = false
        } else {
            profilePicture.alpha = 1
            activityView.hidden = true
        }
    }
    
    @IBAction func profilePicturePressed(sender: AnyObject) {
        if !isCurrentUsersProfile() {
            return
        }
        let alertController = UIAlertController(title: nil, message: "Change profile picture", preferredStyle: .ActionSheet)
        
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            if let image = image {
                self.userImage = image
                self.uploadProfilePicture()
            }
        }
    }
    
    func uploadProfilePicture() {
        let imageData = UIImageJPEGRepresentation(self.userImage, 0.8)
        let imageFile = PFFile(data: imageData)
        
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        self.isPhotoUploading = true
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            self.isPhotoUploading = false
        }
        
        
//        let user = PFObject(className: "_User")

        if let user = PFUser.currentUser() {
            user["profilePicture"] = imageFile
            user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                self.profile?.imageFile = imageFile
                self.profile?.retrieveImage()
                self.reloadProfilePicture()
            }
            
        }
    }

    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        tabBarController?.selectedIndex = 0
    }

    func isCurrentUsersProfile() -> Bool {
        println(profile?.username.value)
        println(PFUser.currentUser()!.username)
        println((profile?.username.value == PFUser.currentUser()!.username))
        return (profile?.username.value == PFUser.currentUser()!.username)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func +(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
}

func -(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}
