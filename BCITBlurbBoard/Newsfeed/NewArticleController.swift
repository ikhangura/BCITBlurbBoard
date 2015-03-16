//
//  NewArticleController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import Alamofire

class NewArticleController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnBackPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Send entry to API
    
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissSelf()
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissSelf()
    }
    
    func updateExpiryField() {
        
    }
    
    // Dismiss view
    func dismissSelf() {
        [self .dismissViewControllerAnimated(true, completion: nil)]
    }
    
}