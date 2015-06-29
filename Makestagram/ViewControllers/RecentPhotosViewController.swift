//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Eugene Yurtaev on 23/06/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit
import ParseUI

class RecentPhotosViewController: UIViewController, TimelineQueryDelegate {
    
    var photoTakingHelper: PhotoTakingHelper?
    var parseLoginHelper: ParseLoginHelper?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self
        
        self.tabBarController?.delegate = self
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
                // Initialize the ParseLoginHelper with a callback
                if let error = error {
                    // 1
                    ErrorHandling.defaultErrorHandler(error)
                } else  if let user = user {
                    // if login was successful, display the TabBarController
                    // 2
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                }
            }
            let loginViewController = PFLogInViewController()
            loginViewController.fields = .UsernameAndPassword | .LogInButton | .SignUpButton | .PasswordForgotten | .Facebook
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController?.delegate = parseLoginHelper
            presentViewController(loginViewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        ParseHelper.timelineRequestforCurrentUser(range) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            let posts = result as? [Post] ?? []
            completionBlock(posts)
        }
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper =
            PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
                let post = Post()
                post.image.value = image
                post.uploadPost()
        }
        
    }
    
    

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TimelineSegue" {
            if let destinationVC = segue.destinationViewController as? TimelineTableViewController {
                destinationVC.timelineQueryDelegate = self
            }
        }
    }
    
}


// MARK: Tab Bar Delegate

extension RecentPhotosViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        }
        return true
    }
    
}

