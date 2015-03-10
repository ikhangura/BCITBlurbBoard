//
//  ViewController.swift
//  BCITBlurbBoard
//
//  Created by Ben Soer on 2015-01-07.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import AlamoFire

class LoginController: UIViewController {
    
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField! //is actualy the email input
    @IBOutlet var error: UILabel!
    
    //user data variables  to be deprecated
    var token:String = "";
    var type:String = "";
    
    let errorMessage:String = "The Email/Password is Incorrect";
    let baseUrl:String = "http://api.thunderchicken.ca/api";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //closes keyboard when user clicks the done key
    @IBAction func textFieldDoneEditing(sender: UITextField){
        sender.resignFirstResponder();
    }
    
    //closes the keyboard when user taps the background
    @IBAction func backgroundTap(sender: UIControl){
        username.resignFirstResponder();
        password.resignFirstResponder();
    }

    @IBAction func LoginUser(sender: UIButton) {
        
        
        println( "User logging in!" )
        
        //client side validation
        if(!validateEmail(username.text) || !validatePassword((password.text)) ){
            error.text = self.errorMessage;
            return;
        }
        let validEmail = username.text!;
        let validPassword = password.text!;
        
        
        //server call
        var loginInfo:[String:AnyObject] = ["email":validEmail, "password": validPassword];
        let route = baseUrl + "/auth";

        
        Alamofire.request(.POST, route, parameters: loginInfo, encoding: .JSON)
            .responseJSON{ (_, _, data, _) in
                
                println("Response Arrived!");
            
                //parse with SwiftlyJSON (located in /Common)
                let json = JSON(data!);

                if var statuscode = json["statuscode"].int {
                    if (statuscode == 200){
                        //proceed user
                        self.logUserIn(json);
                    }else{
                        if var logMessage = json["message"].string{
                            let message:String = "\(statuscode) : \(logMessage)";
                            println(message);
                            self.error.text = self.errorMessage;
                            return;
                        }
                    }
                }
                
                
            }
        }
    
    private func logUserIn(json:JSON){
        
        let appData = GlobalAppData.getGlobalAppData();
        
        
        //set user data, such as user token
        if let userToken = json["data"]["token"].string {
            self.token = userToken;
            appData.setUserToken(userToken);
            
        }
        // and usertype
        if let userType = json["data"]["usertype"].string {
            self.type = userType;
            appData.setUserType(userType);
        }
        //send device token back to server
        if(!sentDeviceToken()){
            println("Failed to send device token. Some functionality may not work. Re-login to try again");
        }
        
        //send to newsfeed page
        var storyboard = UIStoryboard(name : "NewsfeedStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("newsfeed") as UIViewController;
        let dstController = controller as NewsfeedController;
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    private func sentDeviceToken() -> Bool{
        
        return false;
    }
    
    private func validateEmail(email:NSString) -> Bool{
        
        let uString = email as String;
        
        //starts with any letters or numbers
        //then an @ which after may or may not have my.
        //then ends with bcit.ca
        let emailRegex = "^[A-Za-z0-9]*@(my.)?bcit.ca$";
        
        if let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex){
            return emailTest.evaluateWithObject(email);
        }
        
        return false;
        
    }
    
    private func validatePassword(password:NSString) -> Bool {
        
        let pString = password as String;
        
        //check is not empty
        if(pString.isEmpty){
            return false;
        }
        
        return true;
    }

}

