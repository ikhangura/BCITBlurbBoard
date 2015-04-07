
//
//  ContactsController.swift
//  BCITBlurbBoard
//
//  Created by alan on 2/4/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//


import UIKit
import Alamofire



class ContactsController: UIViewController , UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{
    
    let appData = GlobalAppData.getGlobalAppData();
    // search contact api route
    //POST /api/contacts/:userid/search/:token
  
    @IBOutlet var searchController: UISearchDisplayController!
   

    
    let baseUrl:String = "http://api.thunderchicken.ca/api/contacts/";
    
    
    @IBOutlet var tableView: UITableView!
    
    
     var is_searching:Bool!   // It's flag for searching

    @IBAction func btnBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
        var tableData = [JSON]()
        var myFilterData = [JSON]()
   
    var tableViewController = UITableViewController (style: .Plain)
    var filteredTableData = [String]()
    
   
    var cellVal : String?
        override func viewDidLoad() {
        
        super.viewDidLoad()
       
         is_searching = false
        let token:String! = appData.getUserToken();
        let userId:String! = appData.getUserId()
        let searchurl: String = baseUrl + userId + "/search/" + token;
        
              self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        
        Alamofire.request(.GET, baseUrl + userId + "/" + token)
            .responseJSON { (_,_, json, _) in
        
              
            println(json)
            if json != nil {
                var jsonObj = JSON(json!)
                if let data = jsonObj["data"]["contacts"].arrayValue as [JSON]?{
                     self.tableData = data
                     self.tableView.reloadData();
                    
                }
               
            }
        }
       
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be ecreated.
    }
    
    /* Implemented case senstive search function */
   /* Filter Json data to find a specific contact */
    
      func filterTableViewForEnterText(searchText: String)
    {
        
      
        self.myFilterData = self.tableData.filter({( strCountry : JSON) -> Bool in
            
            println(strCountry["name"].string)
            var test = strCountry["name"].string
            var stringForSearch = test?.rangeOfString(searchText)
            println(searchText)
            println(stringForSearch)
            return (stringForSearch != nil)
        })
    }
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterTableViewForEnterText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!,
        shouldReloadTableForSearchScope searchOption: Int) -> Bool {
            let textScope = self.searchDisplayController!.searchBar.scopeButtonTitles as [String]
            self.filterTableViewForEnterText(self.searchDisplayController!.searchBar.text)
            return true
    }
    
/*Search function end here */
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell",forIndexPath: indexPath) as UITableViewCell
        
        let data = self.tableData[indexPath.row]
       
        if tableView == self.searchDisplayController!.searchResultsTableView
        {
            let data2 = self.myFilterData[indexPath.row]
            cellVal = data2["name"].string
            
        }

        else
        {
        cellVal = data["name"].string
        
        }
        cell.textLabel?.text = cellVal
       
        return cell
    }
   
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView
        {
            return self.myFilterData.count
        }
        else{
                      return tableData.count
        }
       
        //return self.contactsData!.toInt()!
       
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = self.tableData[indexPath.row]
        var storyboard = UIStoryboard(name : "SingleContactStoryboard", bundle: nil);
        var controller = storyboard.instantiateViewControllerWithIdentifier("singlecontact") as UIViewController;
        let dstController = controller as SingleContactController;
        
        /*send  this userid to single contact page to get details*/
        /*Choose contact Id based on filter search */
        
        if tableView == self.searchDisplayController!.searchResultsTableView
        {
          let data1 = self.myFilterData[indexPath.row]
            dstController.lblContactId = data1["userid"].string!
        }
        else
        {
             dstController.lblContactId = data["userid"].string!
        }
        
        
         //println(data["name"].string!)
       self.presentViewController(controller, animated: true, completion: nil);
    }
    

    
}
