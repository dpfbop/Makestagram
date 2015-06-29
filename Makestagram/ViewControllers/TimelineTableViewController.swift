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

class TimelineTableViewController: UITableViewController, TimelineComponentTarget {

    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent<Post, TimelineTableViewController>!
    var timelineQueryDelegate: TimelineQueryDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        timelineComponent = TimelineComponent(target: self)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell") as! UITableViewCell
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
    
}
