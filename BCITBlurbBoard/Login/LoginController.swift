//
//  ViewController.swift
//  BCITBlurbBoard
//
//  Created by Ben Soer on 2015-01-07.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginUser(sender: UIButton) {
        println( "User logging in!" )
        
        //TODO : Add actual verification for user auth
        let auth = true;
        if (auth)
        {
            // Set user data, such as usertoken
            // Send device token back to server
            
            // Send to Newsfeed page
            var storyboard = UIStoryboard(name : "NewsfeedStoryboard", bundle: nil);
            var controller = storyboard.instantiateViewControllerWithIdentifier("newsfeed") as UIViewController;
            let dstController = controller as NewsfeedController;
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

}

