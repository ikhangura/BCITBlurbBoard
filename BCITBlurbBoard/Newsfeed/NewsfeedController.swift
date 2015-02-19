//
//  NewsfeedController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
class NewsfeedController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
        
    @IBOutlet
    var tableView: UITableView!
    
    let news1: [String] = ["Woop woop!", "This is a summary of everything that might be in this post. How exciting!",
        "Posted February 16, 2015", "D'Arcy Smith, Faculty of Computing", "12"]
    let news2: [String] = ["Hubba Bubba: Old News or Retro Cool?", "Gum is making a comeback according to a crack team of researchers at BCIT's Burnaby, BC, Canada campus.","Posted February 16, 2015", "Matthew Banman, CST", "3"]
    let items: [String[]] = [news1, news2]
    
    // table view methods
    
    override func numberOfSections() -> Int
    {
        return 1
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        return self.items.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell! = self.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        cell.
           
        return UITableViewCell()
    }
    
    func tableView(tableView : UITableView, didSelectRowAtIndexPath indexPath : NSIndexPath)
    {

    }
    
    // end table view methods
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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