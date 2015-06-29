//
//  UserViewCell.swift
//  Makestagram
//
//  Created by Eugene Yurtaev on 25/06/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

protocol FriendSearchTableViewCellDelegate: class {
    func cell(cell: UserViewCell, didSelectFollowUser user: PFUser)
    func cell(cell: UserViewCell, didSelectUnfollowUser user: PFUser)
}


class UserViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate : FriendSearchTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            userLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet {
            /*
            Change the state of the follow button based on whether or not
            it is possible to follow a user.
            */
            if let canFollow = canFollow {
                followButton.selected = !canFollow
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func followButtonTapped(sender: AnyObject) {
        if let canFollow = canFollow where canFollow == true {
            delegate?.cell(self, didSelectFollowUser: user!)
            self.canFollow = false
        } else {
            delegate?.cell(self, didSelectUnfollowUser: user!)
            self.canFollow = true
        }
    }

}
