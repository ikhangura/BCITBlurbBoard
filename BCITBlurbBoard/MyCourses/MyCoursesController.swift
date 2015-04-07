//
//  MyCoursesController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import Alamofire

struct CourseItem
{
    var index           : Int
    var coursesectionid : String
    var courseid        : String
    var coursename      : String
    var teachername     : String
    var datetimestart   : String
    var datetimeend     : String
}

class MyCoursesController : UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yourNameLabel: UILabel!
    @IBOutlet weak var facultyLabel: UILabel!
    @IBOutlet weak var programLabel: UILabel!
    
    // class variables
    var courseArray : [CourseItem] = []
    let cellIdentifier : String = "courseCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.courseArray = Array()
        
        // get news via Alamofire API call
        self.getCourses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    // returns the number of items to display!
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        return self.courseArray.count
    }
    
    // returns the number of sections in this table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    // returns the height of a single cell
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
    }
    
    // building a table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : CourseCell!      = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as CourseCell
        
        cell.courseTitleLabel.text  = self.courseArray[indexPath.row].coursename
        cell.courseDatesLabel.text  = "\(self.courseArray[indexPath.row].datetimestart) - \(self.courseArray[indexPath.row].datetimeend)"
        cell.instructorLabel.text   = self.courseArray[indexPath.row].teachername
        
        return cell
    }
    
    // run on selecting a news item at a specific index
    func tableView(tableView : UITableView, didSelectRowAtIndexPath indexPath : NSIndexPath)
    {
        // do some stuff here
        var storyboard = UIStoryboard(name : "FilteredNewsfeedStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("filterednewsfeed") as UIViewController;
        let dstController = controller as FilteredNewsfeedController;
        dstController.coursesectionID = courseArray[indexPath.row].coursesectionid
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    //alamofire info
    
    
    func getCourses()
    {
        let appData : GlobalAppData! = GlobalAppData.getGlobalAppData()
        let uid = appData.getUserId()
        let token = appData.getUserToken()
        let route : String = "http://api.thunderchicken.ca/api/mycourses/" + uid! + "/" + token!
        
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
                        self.displayCourseItems(json["data"]["courses"].arrayValue)
                        self.yourNameLabel.text = json["data"]["name"].stringValue
                        self.programLabel.text = json["data"]["programname"].stringValue
                        self.facultyLabel.text = json["data"]["facultyname"].stringValue
                        self.tableView.reloadData()
                        
                        println(json)
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
    
    @IBAction func btnBackCoursesPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func displayCourseItems(json : [JSON])
    {
        var count = 0
        
        for j in json
        {
            // if this is not the "all" course used to post to everyone...
            if( j["courseid"].stringValue != "10" )
            {
                var ni : CourseItem = CourseItem(
                    index           : count,
                    coursesectionid : j["coursesectionid"].stringValue,
                    courseid        : j["courseid"].stringValue,
                    coursename      : j["coursename"].stringValue,
                    teachername     : j["teachername"].stringValue,
                    datetimestart   : j["datetimestart"].stringValue,
                    datetimeend     : j["datetimeend"].stringValue
                )
                
                self.courseArray.append(ni)
                count++
            }
        }
        
    }

}
