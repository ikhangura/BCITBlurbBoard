//
//  SingleArticleController.swift
//  BCITBlurbBoard
//
//  Created by alan on 3/11/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//


import UIKit
import Foundation
import AlamoFire

class SingleArticleController: UIViewController, UITableViewDataSource, UITextViewDelegate {
    private struct ArticleComment
    {
        var Comment : String;
        var Username : String;
        var Time : String;
    }
    
    private struct ArticleDetails
    {
        var id : String;
        var title : String;
        var content : String;
        var authorname : String;
        var authorID : String;
        var postDate : String;
    }
    
    @IBOutlet weak var txtReply: UITextView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var txtArticleContent: UITextView!
    @IBOutlet weak var lblArticleTime: UILabel!
    @IBOutlet weak var lblArticleAuthor: UILabel!
    @IBOutlet weak var tblComment: UITableView!
    @IBOutlet weak var lblPostStatus: UILabel!
    
    var articleID : String!;
    
    private var baseUrl:String?;
    private var routeGetArticleWithComments:String?;
    private var routeNewCommentForArticle:String?;
    private let USERINFO = GlobalAppData.getGlobalAppData();
    private var userID : String?;
    private var userToken : String?;
    
    private var articleCommentArray : [ArticleComment]!;
    private var articleDetails : ArticleDetails?;
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userID = USERINFO.getUserId();
        userToken = USERINFO.getUserToken();
        baseUrl = "http://api.thunderchicken.ca/api";
        
        //  /api/newsfeed/{userid}/artcile/{newsid}/{token}
        routeGetArticleWithComments = baseUrl! + "/newsfeed/" + userID! + "/article/" + articleID + "/" + userToken!;
        
        // POST /api/newsfeed/:userid/article/:articleid/comment/:token
        routeNewCommentForArticle = baseUrl! + "/newsfeed/" + userID! + "/article/" + articleID + "/comment/" + userToken!;
        loadData();
        txtReply.delegate = self;
        
        
        txtReply.layer.borderColor = UIColor.grayColor().CGColor
        txtReply.layer.borderWidth = 0.2
        txtReply.layer.cornerRadius = 5.0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindArticleDataToView()
    {
        txtArticleContent.text = articleDetails?.content;
        lblArticleAuthor.text = articleDetails?.authorname;
        lblArticleTime.text = articleDetails?.postDate;
        navTitle.title = articleDetails?.title;
        txtReply.text.removeAll(keepCapacity: false);
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        println("Getting rows for table");
        return articleCommentArray!.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // select template cell with its reuseIdentifier
        let cell: SingleArticleCellControllerTableViewCell = tableView.dequeueReusableCellWithIdentifier("cellComment", forIndexPath: indexPath) as SingleArticleCellControllerTableViewCell;
        let comments : [ArticleComment]! = articleCommentArray;
        cell.lblUser.text = comments[indexPath.row].Username;
        cell.lblTime.text = comments[indexPath.row].Time;
        cell.txtComment.text = comments[indexPath.row].Comment;
        println("Created cell with value:");
        println(comments[indexPath.row].Username);
        println(comments[indexPath.row].Time);
        println(comments[indexPath.row].Comment);
        
//        cell.lblUser.text = "Alan";
//        cell.lblTime.text = String(indexPath.row);
//        cell.txtComment.text = "Comment";
        return cell
    }
    
    func loadData()
    {
        Alamofire.request(.GET, routeGetArticleWithComments!)
            .responseJSON{ (req, res, data, error) in
                
                println("Single Article Response!");
                
                //parse with SwiftlyJSON (located in /Common)
                let json = JSON(data!);
                
                if var statuscode = json["statuscode"].int
                {
                    if (statuscode == 200)
                    {
                        // Data successfully received
                        self.parseComments(json["data"]["comments"].arrayValue);
                        self.parseArticleDetails(json);
                        println("At end of parse");
                        self.bindArticleDataToView();
                        self.tblComment.dataSource = self;
                        self.tblComment.reloadData();
                        return;
                    }
                    else
                    {
                        if var logMessage = json["message"].string
                        {
                            let message:String = "\(statuscode) : \(logMessage)";
                            println(message);
                            return;
                        }
                    }
                }
        }
        println("At end of loadData");
    }

    
    private func parseComments(commentsArray : [JSON])
    {
        self.articleCommentArray = [];
        for singleComment in commentsArray
        {
            let comment = ArticleComment(Comment: singleComment["content"].stringValue,
                Username: singleComment["name"].stringValue,
                Time: singleComment["datetime"].stringValue);
            self.articleCommentArray!.append(comment);
        }
    }
    
    private func parseArticleDetails(data : JSON)
    {
        let _id = data["data"]["newsid"].stringValue;
        let _title = data["data"]["title"].stringValue;
        let _content = data["data"]["content"].stringValue;
        let _authorname = data["data"]["authorname"].stringValue;
        let _authorID = data["data"]["authorid"].stringValue;
        let _postDate = data["data"]["datetime"].stringValue;
        self.articleDetails = ArticleDetails(id: _id,
            title: _title,
            content: _content,
            authorname: _authorname,
            authorID: _authorID,
            postDate: _postDate);
    }
    
    @IBAction func btnPostPressed(sender: UIButton) {
        let data : [String:AnyObject] = ["content":txtReply.text];
        Alamofire.request(.POST, routeNewCommentForArticle!, parameters: data, encoding: .JSON)
            .responseJSON{ (req, res, data, error) in
                
                println("Post Comment Response!");
                
                //parse with SwiftlyJSON (located in /Common)
                let json = JSON(data!);
                println(data);
                if var statuscode = json["statuscode"].int
                {
                    if (statuscode == 201)
                    {
                        // Data successfully received
                        self.txtReply.text.removeAll(keepCapacity: false);
                        self.lblPostStatus.text = "Your comment has been posted";
                        return;
                    }
                    else
                    {
                        if var logMessage = json["message"].string
                        {
                            let message:String = "\(statuscode) : \(logMessage)";
                            println(message);
                            return;
                        }
                    }
                }
        }
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    func textView(textView: UITextView!, shouldChangeTextInRange: NSRange, replacementText: NSString!) -> Bool {
        if(replacementText == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
