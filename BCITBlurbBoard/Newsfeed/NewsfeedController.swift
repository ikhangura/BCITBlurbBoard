//
//  NewsfeedController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import Alamofire

class NewsfeedController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    // class variables
    let cellIdentifier : String = "newsCell"
    let route : String = "http://api.thunderchicken.ca/api/newsfeed"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // get news via Alamofire API call
        getNews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let items: [[String]] = [
        ["Woop woop!", "This is a summary of everything that might be in this post. How exciting!",
            "Posted February 16, 2015", "D'Arcy Smith, Faculty of Computing", "12"],
        ["Hubba Bubba: Old News or Retro Cool?", "Gum is making a comeback according to a crack team of researchers at BCIT's Burnaby, BC, Canada campus.","Posted February 16, 2015", "Matthew Banman, CST", "3"]]
    
    // returns the number of items to display!
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        return self.items.count
    }
    
    // returns the number of sections in this table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // returns the height of a single cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 160
    }
    
    // building a table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : NewsItemCell!         = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as NewsItemCell
        cell.CellTitle.text              = items[indexPath.row][0]
        cell.MessagePreview.text         = items[indexPath.row][1]
        cell.Date.text                   = items[indexPath.row][2]
        cell.Author.text                 = items[indexPath.row][3]
        cell.CommentNum.text             = items[indexPath.row][4]
        
        return cell
    }
    
    // run on selecting a news item at a specific index
    func tableView(tableView : UITableView, didSelectRowAtIndexPath indexPath : NSIndexPath)
    {
        // do some stuff here
    }
    
    //alamofire info
    
    
    func getNews()
    {
        let appData : GlobalAppData! = GlobalAppData.getGlobalAppData()
        let uid = appData.getUserId()
        var userId:[String:AnyObject] = ["userid" : uid ]
        
        Alamofire.request(.GET, route, parameters: userId, encoding: .JSON)
            .responseJSON{ (_, _, data, _) in
                
                println("News response Arrived!")
                //self.loader.stopAnimating()
                
                //parse with SwiftlyJSON (located in /Common)
                let json = JSON(data!)
                
                if var statuscode = json["statuscode"].int
                {
                    if (statuscode == 200)
                    {
                        //proceed news items!
                        self.displayNewsItems(json)
                    }
                    else
                    {
                        if var logMessage = json["message"].string{
                            let message:String = "\(statuscode) : \(logMessage)"
                            println(message)
                            //self.error.text = self.errorMessage.string
                            return
                    }
                }
            }
        }
    }
    
    func displayNewsItems(json : JSON)
    {
        
    }
    
    // end TableView stuff

    @IBAction func btnLogoutPressed(sender: UIButton)
    {
        // Do logout things 
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    @IBAction func btnContactsPressed(sender: UIButton)
    {
        var storyboard = UIStoryboard(name : "ContactsStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("contacts") as UIViewController;
        let dstController = controller as ContactsController;
        self.presentViewController(controller, animated: true, completion: nil);
    }
    @IBAction func btnMyCoursesPressed(sender: UIButton) {
        var storyboard = UIStoryboard(name : "MyCoursesStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("mycourses") as UIViewController;
        let dstController = controller as MyCoursesController;
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    
}