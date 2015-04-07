//
//  NewsfeedController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import Alamofire

struct NewsItem
{
    var index : Int
    
    var newsid : String
    var title : String
    var content : String
    var userid : String
    var author : String
    var datetime : String
    var numComments : String
}

class NewsfeedController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    // class variables
    var newsArray : [NewsItem] = []
    let cellIdentifier : String = "newsCell"
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.newsArray = Array()
        
        configureTableView()
        
        // get news via Alamofire API call
        getNews()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        getNews()
        self.refreshControl.endRefreshing()
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
        return self.newsArray.count
    }
    
    // returns the number of sections in this table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // returns the height of a single cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 135
    }
    
    // building a table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : NewsItemCell!         = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as NewsItemCell
        cell.CellTitle.text              = self.newsArray[indexPath.row].title
        cell.MessagePreview.text         = self.newsArray[indexPath.row].content
        cell.Date.text                   = self.newsArray[indexPath.row].datetime
        cell.Author.text                 = self.newsArray[indexPath.row].author
        cell.CommentNum.text             = self.newsArray[indexPath.row].numComments
        
        return cell
    }
    
    // run on selecting a news item at a specific index
    func tableView(tableView : UITableView, didSelectRowAtIndexPath indexPath : NSIndexPath)
    {
        // do some stuff here
        var storyboard = UIStoryboard(name : "SingleArticleStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("singlearticle") as UIViewController;
        let dstController = controller as SingleArticleController;
        dstController.articleID = newsArray[indexPath.row].newsid
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    //alamofire info
    
    
    func getNews()
    {
        let appData : GlobalAppData! = GlobalAppData.getGlobalAppData()
        let uid = appData.getUserId()
        let token = appData.getUserToken()
        let route : String = "http://api.thunderchicken.ca/api/newsfeed/" + uid! + "/standard/" + token!
        
        Alamofire.request(.GET, route)
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
                        self.displayNewsItems(json["data"]["news"].arrayValue)
                        self.tableView.reloadData()
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
    
    func displayNewsItems(json : [JSON])
    {
        var count = 0
        
        newsArray.removeAll(keepCapacity: false)
        
        for j in json
        {
            var ni : NewsItem = NewsItem(
                index        : count,
                newsid       : j["newsid"].stringValue,
                title        : j["title"].stringValue,
                content      : j["content"].stringValue,
                userid       : j["userid"].stringValue,
                author       : j["author"].stringValue,
                datetime     : j["datetime"].stringValue,
                numComments  : j["numcomments"].stringValue
            )
            
            self.newsArray.append(ni)
            count++
        }
        
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 105.0
    }
    
    // end TableView stuff
    
    @IBAction func btnLogoutPressed(sender: AnyObject) {
        let appData = GlobalAppData.getGlobalAppData();
        appData.setUserToken("");
        appData.setUserType("");
        appData.setUserId("");
        appData.setUserName("");
        
        var storyboard = UIStoryboard(name : "Main", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("login") as UIViewController;
        let dstController = controller as LoginController;
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func btnContactPressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name : "ContactsStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("contacts") as UIViewController;
        let dstController = controller as ContactsController;
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    @IBAction func btnCoursesPressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name : "MyCoursesStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("mycourses") as UIViewController;
        let dstController = controller as MyCoursesController;
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
}