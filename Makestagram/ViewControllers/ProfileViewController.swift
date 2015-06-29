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

class ProfileViewController: UIViewController, TimelineQueryDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var userImage: UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var isPhotoUploading = false
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var spaceToProfileView: NSLayoutConstraint!
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
                self.profile = Profile(user: curUser, imageFile: curUser["profilePicture"] as? PFFile)
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
            self.navigationItem.title = profile?.username.value
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.title = "Your profile"
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
        let alertView = UIAlertView(title: "Logout", message: "Do you really want to logout?", delegate: self, cancelButtonTitle: "Cancel")
        alertView.addButtonWithTitle("Yes")
        alertView.show()
    }

    func isCurrentUsersProfile() -> Bool {
        println(profile?.username.value)
        println(PFUser.currentUser()!.username)
        println((profile?.username.value == PFUser.currentUser()!.username))
        return (profile?.username.value == PFUser.currentUser()!.username)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProfileSegue" {
            if let destinationVC = segue.destinationViewController as? TimelineTableViewController {
                destinationVC.timelineQueryDelegate = self
                destinationVC.scrollViewDelegate = self
                destinationVC.isProfile = true
            }
        }
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        ParseHelper.postsForUser(range, user: self.profile!.user!) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            let posts = result as? [Post] ?? []
            completionBlock(posts)
        }
    }
    
}

extension ProfileViewController: ContentOffsetDelegate {
    func didScrollTo(scrollOffset: CGPoint) {
        let shift = max(200 - scrollOffset.y, 0)
        profileViewHeightConstraint.constant = max(200 - scrollOffset.y, 0)
    }
}

extension ProfileViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
                    PFUser.logOut()
                    tabBarController?.selectedIndex = 0
        }
    }
}

func +(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
}

func -(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}
