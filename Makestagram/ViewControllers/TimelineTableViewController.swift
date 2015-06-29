//
//  TimelineTableViewController.swift
//  Makestagram
//
//  Created by Eugene Yurtaev on 29/06/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

protocol TimelineQueryDelegate {
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void)
}

protocol ContentOffsetDelegate {
    func didScrollTo(scrollOffset: CGPoint)
}

class TimelineTableViewController: UITableViewController, TimelineComponentTarget {
    @IBOutlet weak var headerView: UIView!

    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent<Post, TimelineTableViewController>!
    var timelineQueryDelegate: TimelineQueryDelegate?
    var scrollViewDelegate: ContentOffsetDelegate?
    var isProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        timelineComponent = TimelineComponent(target: self)
        
        if isProfile {
            headerView.frame = CGRectMake(0, 0, 0, 200)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        timelineQueryDelegate?.loadInRange(range, completionBlock: completionBlock)
    }

    @IBAction func doubleTapOnPhoto(sender: UITapGestureRecognizer) {
        let locationInTableView = sender.locationInView(tableView)
        let indexPathOfTappedCell = tableView.indexPathForRowAtPoint(locationInTableView)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollViewDelegate?.didScrollTo(tableView.contentOffset)
    }
    

}

extension TimelineTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.timelineComponent.content.count == 0 {
            return 1
        }
        return self.timelineComponent.content.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if self.timelineComponent.content.count == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell") as! UITableViewCell
            return cell
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.section]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    }
    
}

extension TimelineTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.timelineComponent.content.count == 0 {
            return 0
        }
        return 40
    }
    
   override  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.timelineComponent.content.count == 0 {
            return tableView.frame.size.height
        }
        return 470
    }
    
    
}
