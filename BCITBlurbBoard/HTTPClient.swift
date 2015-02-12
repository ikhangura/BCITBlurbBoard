//
//  HTTPClient.swift
//  BCITBlurbBoard
//
//  Created by Matthew Banman on 2015-02-11.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import Foundation
import Alamofire

// private instance of HTTPClient to allow for singleton
private let _HTTPClientSharedInstance = HTTPClient()

// HTTPClient class facilitates connection to REST APIs via Alamofire
class HTTPClient
{
    
    // HTTP Get function that returns JSON - to be parsed and used by individual classes
    // takes in parameters to be sent in JSON body to API route
    func Get( URLString : String, data : Dictionary<String, String> )
    {
        
        Alamofire.request( .GET, URLString, parameters : data )
            .responseJSON
            {
                ( _, _, JSON, _ ) in
                println( JSON )
            }
    }
    
    // HTTP Get function that returns JSON - to be parsed and used by individual classes
    func Get( URLString : String )
    {
        
        var result : String!
        
        Alamofire.request( .GET, URLString )
            .responseJSON
            {
                ( _, _, JSON, _ ) in
                println(JSON)
            }
    }
    
    // HTTP Post function that returns JSON - to be parsed and used by individual classes
    // takes in parameters to be sent in JSON body to API route
    func Post( URLString : String, data : Dictionary<String, String> )
    {
        Alamofire.request( .POST, URLString, parameters : data )
            .responseJSON
            {
                ( _, _, JSON, _ ) in
                println( JSON )
            }
    }
    
    // Test Get function that prints JSON result
    func TestGet( URLString : String, data : Dictionary<String, String> )
    {
        
        Alamofire.request( .GET, URLString, parameters : data )
            .responseJSON
            {
                ( _, _, JSON, _ ) in
                println( JSON )
        }
    }
    
    // Test Get function that prints JSON result
    func TestGet( URLString : String )
    {
        
        Alamofire.request( .GET, URLString )
            .responseJSON
            {
                ( _, _, JSON, _ ) in
                println( JSON )
        }
    }
    
    // Test Post function that prints JSON result
    func TestPost( URLString : String, data : Dictionary<String, String> )
    {
        Alamofire.request( .POST, URLString, parameters : data )
            .responseJSON
            {
                ( _, _, JSON, _ ) in
                println( JSON )
        }
    }
    
    // The shared instance of HTTPClient - accessed through HTTPClient.sharedInstance
    class var sharedInstance: HTTPClient
    {
        return _HTTPClientSharedInstance
    }
}