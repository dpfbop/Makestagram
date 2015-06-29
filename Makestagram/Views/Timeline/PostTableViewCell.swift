//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Eugene Yurtaev on 24/06/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    
    var post:Post? {
        didSet {
            if let oldValue = oldValue where oldValue != post {
                // 2
                likeBond.unbindAll()
                postImageView.designatedBond.unbindAll()
                // 3
                if (oldValue.image.bonds.count == 0) {
                    oldValue.image.value = nil
                }
            }
            
            if let post = post {
                // bind the image of the post to the 'postImage' view
                post.image ->> postImageView
                
                // bind the likeBond that we defined earlier, to update like label and button when likes change
                post.likes ->> likeBond
            }
        }
    }
    
    var likeBond: Bond<[PFUser]?>!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeButtonLabel: UILabel!

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 1
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
            // 2
            if let likeList = likeList {
                // 3
                self.likesLabel.text = self.stringFromUserList(likeList)
                // 4
                self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
                if self.likeButton.selected {
                    self.likeButtonLabel.textColor = self.tintColor
                } else {
                    self.likeButtonLabel.textColor = UIColor.blackColor()
                }
                // 5
                self.likesIconImageView.hidden = (likeList.count == 0)
            } else {
                // 6
                // if there is no list of users that like this post, reset everything
                self.likesLabel.text = ""
                self.likeButton.selected = false
                self.likesIconImageView.hidden = true
            }
        }
        
        var recognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        recognizer.numberOfTapsRequired = 2
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
        
    }
    
    
    func handleDoubleTap(recognizer: UIPanGestureRecognizer) {
        let locationOfTap = recognizer.locationInView(self.postImageView)
        if locationOfTap.y > self.postImageView.frame.height {
            return
        }
        
        if let post = post {
            if !post.doesUserLikePost(PFUser.currentUser()!) {
                post.toggleLikePost(PFUser.currentUser()!)
            }
        }
        // self.postImageView.center
        var makeSchoolImage = UIImage(named: "Makeschool_selected")
        var makeSchoolImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        makeSchoolImageView.image = makeSchoolImage
        self.postImageView.addSubview(makeSchoolImageView)
        makeSchoolImageView.center = self.postImageView.center
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            makeSchoolImageView.alpha = 0
            makeSchoolImageView.frame = CGRect(x: 0, y: 0, width: 160, height: 160)
            makeSchoolImageView.center = self.postImageView.center
        }) { (error) -> Void in
            makeSchoolImageView.removeFromSuperview()
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func likeButtonTapped(sender: UIButton) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }

    @IBAction func moreButtonTapped(sender: UIButton) {
        
    }
    
    func stringFromUserList(userList: [PFUser]) -> String {
        // 1
        let usernameList = userList.map { user in user.username! }
        // 2
        let commaSeparatedUserList = ", ".join(usernameList)
        
        return commaSeparatedUserList
    }
}
