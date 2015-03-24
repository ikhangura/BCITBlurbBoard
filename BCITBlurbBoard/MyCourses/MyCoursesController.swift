//
//  MyCoursesController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import alamofire

struct CourseItem
{
    var index : Int
    
    var courseid : String
    var coursetitle : String
    var dates : String
    var roomnumber : String
    var instructor : String
}

class MyCoursesController : UIViewController, UITableViewDataSource, UITableViewDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}
