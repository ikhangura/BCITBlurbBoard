//
//  NewArticleController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit
import Alamofire

class NewArticleController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var criticalSwitch: UISwitch!
    @IBOutlet weak var expTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var popDatePicker:PopDatePicker?
    private var baseUrl:String!
    private var routeGetPostableContacts:String?
    private var routePostNewsArticle:String?
    private let USERINFO = GlobalAppData.getGlobalAppData()
    private var userID:String?
    private var userToken:String?
    private var msSqlDate:String?
    
    private struct PostableContact {
        var usercoursesectionid:String
        var usercoursesectionname:String
    }
    
    private var postableContacts:[PostableContact]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data and API
        userID = USERINFO.getUserId()
        userToken = USERINFO.getUserToken()
        
        // base url of api server
        baseUrl = "http://api.thunderchicken.ca/api"
        
        // /api/contacts/:userid/postable/:token
        routeGetPostableContacts = baseUrl! + "/contacts/" + userID! + "/postable/" + userToken!
        
        // /api/newsfeed/:userid/article/:token
        routePostNewsArticle = baseUrl! + "/newsfeed/" + userID! + "/article/" + userToken!
        
        println("ID: " + userID! + " PW: " + userToken!)
        
        loadPostableContacts()
        
        // Datepicker
        popDatePicker = PopDatePicker(forTextField : expTextField)
        expTextField.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    @IBAction func enterTitle(sender: UITextField) {
//        if (titleField.text != null && receiverField.text != null)
//        {
//            doneButton.enabled = true
//        }
//        else doneButton.enabled = false
//    }
    
    
    // User selects the expiry text field
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField === expTextField) {
            
            // dismiss keyboard
            resign()
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            
            let initDate = formatter.dateFromString(expTextField.text)
            
            popDatePicker!.pick(self, initDate:initDate, dataChanged: { (newDate : NSDate, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                // newDate returns Dec 31, 9999, 11:59 PM if the user press "none"
                forTextField.text = newDate.ToDateMediumString() == "Dec 31, 9999, 11:59 PM" ? "none" : newDate.ToDateMediumString()
                
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" + ":00.000"
                
                // format date to be sent to api
                self.msSqlDate = dateFormatter.stringFromDate(newDate)
                
            })
            return false
        }
        else {
            return true
        }
    }
    
    // Post entry to API
    func sendForm()
    {
        
        let form:[String:AnyObject] = [
            "title": "My Title",
            "coursesectionid": "3",
            "expirydate": expTextField.text == "none" ? "9999-12-31 23:59:59.997" : msSqlDate!,
            "priority": criticalSwitch.on ? "Critical" : "Standard",
            "content": "My Content",
        ]
        Alamofire.request(.POST, routePostNewsArticle!, parameters: form, encoding: .JSON)
        .responseJSON { (req, res, data, error) in
            println("Post Article Response!")
            
            //parse with SwiftlyJSON (located in /Common)
            let json = JSON(data!)
            println("Sending data... ")
            println(form)
            println(data)
            if var statuscode = json["statuscode"].int
            {
                if (statuscode == 201)
                {
                    // Data successfully received
                    println("Data sent!")
                    return
                }
                else
                {
                    if var logMessage = json["message"].string
                    {
                        let message:String = "\(statuscode) : \(logMessage)"
                        println(message)
                        return
                    }
                }
            }
        }
    }

    // Get Postable Contacts from API
    func loadPostableContacts() {
        Alamofire.request(.GET, routeGetPostableContacts!).responseJSON {
            (req, res, data, error) in
            
            println("Postable Contacts Response!")
            
            //parse with SwiftlyJSON (located in /Common)
            let json = JSON(data!)
            
            //print response
            println(data)
            
            if var statuscode = json["statuscode"].int
            {
                if (statuscode == 200)
                {
                    // Data successfully received
                    println("Reading data...")
                    self.parsePostableContacts(json["data"]["usercoursesections"].arrayValue)
                    println("Data read.")
                    return
                }
                else
                {
                    if var logMessage = json["message"].string
                    {
                        let message:String = "\(statuscode) : \(logMessage)"
                        println(message)
                        return
                    }
                }
            }
        }
    }
    
    // Parse Postable Contacts from Get method
    private func parsePostableContacts (contactsArray:[JSON]) {
        for contact in contactsArray {
            let newContact = PostableContact(
                usercoursesectionid: contact["usercoursesectionid"].stringValue,
                usercoursesectionname: contact["usercoursesectionname"].stringValue)
            println(contact)
            self.postableContacts!.append(newContact)
        }
    }
    
    // Navigation buttons
    @IBAction func donePressed(sender: AnyObject) {
        // send form to API
        self.sendForm()
        self.dismissSelf()
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissSelf()
    }
    
    // Dismiss keyboard
    func resign() {
        titleField.resignFirstResponder()
        expTextField.resignFirstResponder()
    }
    
    // Dismiss view
    func dismissSelf() {
        [self.dismissViewControllerAnimated(true, completion: nil)]
    }
    
}