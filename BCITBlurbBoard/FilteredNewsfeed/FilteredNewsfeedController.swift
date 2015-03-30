//
//  NewsfeedController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import Alamofire

struct FilteredNewsItem
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


class FilteredNewsfeedController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var coursesectionID : String!

    @IBOutlet weak var navBar: UINavigationBar!
    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    // class variables
    var newsArray : [FilteredNewsItem] = []
    let cellIdentifier : String = "filterednewsCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.newsArray = Array()
        
        // get news via Alamofire API call
        getNews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    let items: [[String]] = [
//        ["Woop woop!", "This is a summary of everything that might be in this post. How exciting!",
//            "Posted February 16, 2015", "D'Arcy Smith, Faculty of Computing", "12"],
//        ["Hubba Bubba: Old News or Retro Cool?", "Gum is making a comeback according to a crack team of researchers at BCIT's Burnaby, BC, Canada campus.","Posted February 16, 2015", "Matthew Banman, CST", "3"]]
    
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
        return 160
    }
    
    // building a table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : FilteredNewsItemCell!         = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as FilteredNewsItemCell
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
        ///api/newsfeed/:userid/coursesection/:coursesectionid/:token
        let route : String = "http://api.thunderchicken.ca/api/newsfeed/" + uid! + "/coursesection/" + coursesectionID! + "/" + token!
        
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
                        //process news items!
                        let title = String(json["data"]["coursename"].stringValue) + " News";
                        self.navBar.topItem?.title = title;
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
        
        for j in json
        {
            var ni : FilteredNewsItem = FilteredNewsItem(
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
    @IBAction func backButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}