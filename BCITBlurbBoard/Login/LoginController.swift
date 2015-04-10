//
//  ViewController.swift
//  BCITBlurbBoard
//
//  Created by Ben Soer on 2015-01-07.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import AlamoFire
import Darwin

class LoginController: UIViewController {
    
   
    @IBOutlet var criticalnewslabel: UILabel!
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField! //is actualy the email input
    @IBOutlet var error: UILabel!
    @IBOutlet var loader: UIActivityIndicatorView!
        
    let errorMessage:NSMutableAttributedString = NSMutableAttributedString(string: "The Email/Password is Incorrect");
    let baseUrl:String = "http://api.thunderchicken.ca/api";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        error.adjustsFontSizeToFitWidth = true;
        errorMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(0, errorMessage.length));
        self.getCriticalNews();
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getCriticalNews();
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
    
    private func getCriticalNews() {
        println("Login - Calling Critical News");
        let route = baseUrl + "/newsfeed/critical";
        
        
        Alamofire.request(.GET, route)
            .responseJSON{ (_, _, data, _) in
                println("Login - Critical News Recieved");
                if (data == nil) {
                    self.alertNoConnection()
                }
                else {
                    let json = JSON(data!);
                    let count = json["data"]["criticalnews"].array?.count;
                    
                    if(count > 0){
                        var newsText:String = "CRITICAL NEWS\n";
                        for(var i = 0; i < count; i++){
                            if let title = json["data"]["criticalnews"][i]["title"].string {
                                newsText += title + "\n";
                            }
                        }
                        self.criticalnewslabel.text = newsText;
                        self.fadeInBanner();
                        println(newsText)
                    }
                }
            }
    }
    
    private func alertNoConnection() {
        let alertController = UIAlertController(title: "Error!", message:
            "Can't connect to server. Please check if you have internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
        var exitAction = UIAlertAction(title: "Exit", style: UIAlertActionStyle.Default) {
            UIAlertAction in self.exitApp()
        }
        alertController.addAction(exitAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func exitApp() {
        exit(0)
    }
    
    private func fadeInBanner(){
        UIView.animateWithDuration(1.5, animations: {
            self.criticalnewslabel.alpha = 1;
        });
    }

    /// goes through the process of validating the users login information and then makes the call
    /// to the server to validate the user and fetch its token. On success the function calls the
    /// logUserIn function. On failure the function will set all errors to the view and return
    @IBAction func LoginUser(sender: UIButton) {
        
        //clear any error content that may exist
        error.text = "";
        
        println( "Login - User logging in!" )
        loader.startAnimating();
        
        //client side validation
        if(!validateEmail(username.text) || !validatePassword((password.text)) ){
            error.text = self.errorMessage.string;
            
            loader.stopAnimating();
            password.text = ""
            
            UIView.animateWithDuration(1.0, delay: 2.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.error.alpha = 0.0
                }, completion: {
                    (finished: Bool) -> Void in
                    
                    //Once the label is completely invisible, set the text and fade it back in
                    self.error.text = ""
                    
                    // Fade in
                    UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.error.alpha = 1.0
                        }, completion: nil)
            })
            return;
        }
        let validEmail = username.text!;
        let validPassword = password.text!;
        
        
        //server call
        var loginInfo:[String:AnyObject] = ["email":validEmail, "password": validPassword];
        let route = baseUrl + "/auth";

        
        
        Alamofire.request(.POST, route, parameters: loginInfo, encoding: .JSON)
            .responseJSON{ (_, _, data, _) in
                
                println("Login - Response Arrived!");
                self.loader.stopAnimating();
            
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
                            self.error.text = self.errorMessage.string;
                            return;
                        }
                    }
                }
                
                
            }
        }
    
    /// logUserIn goes through the process of setting all of the returned user data from the server
    /// into the GlobalAppData object. It then attempts to send the apple token to the server. After, it
    /// forwards the user to the newsfeed controller
    /// :param: json the json that was returned from the server with the desired user information
    private func logUserIn(json:JSON){
        
        let appData = GlobalAppData.getGlobalAppData();
        
        //set user data, such as user token
        if let userToken = json["data"]["token"].string {
            appData.setUserToken(userToken);
            
        }
        // and usertype
        if let userType = json["data"]["type"].string {
            appData.setUserType(userType);
        }
        
        //and user id
        if let userid = json["data"]["userid"].string{
            appData.setUserId(userid);
        }
        
        //and username
        if let username = json["data"]["name"].string{
            appData.setUserName(username);
        }
        
        //send device token back to server
        if(!sentDeviceToken()){
            println("Login - Failed to send device token. Some functionality may not work. Re-login to try again");
        }
        
        //send to newsfeed page
        var storyboard = UIStoryboard(name : "NewsfeedStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("newsfeed") as UIViewController;
        let dstController = controller as NewsfeedController;
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    /// sends the device token to the server and returns true or false pending on success or
    /// failure of sending the token
    /// :return: Bool the status of whether sending the token succeeded or failed
    private func sentDeviceToken() -> Bool{
        
        return false;
    }
    
    /// validates the text entered in the username field. This text is meant to be an email and is
    /// validated as such so as not to waist server resources
    /// :param: email the string that contains the email to be validated
    /// :return: Bool whether or not the passed in email is valid or not
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
    
    /// validates the text entered in the password field. This field is meant to be a password and
    /// is validated as such so as not to waist server resources
    /// :param: password the string that contains the password to be validated
    /// :return: Bool whether or not the passed in password is valid or not
    private func validatePassword(password:NSString) -> Bool {
        
        let pString = password as String;
        
        //check is not empty
        if(pString.isEmpty){
            return false;
        }
        
        return true;
    }

}

