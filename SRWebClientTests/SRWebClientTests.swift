//
//  SRWebClientTests.swift
//  SRWebClientTests
//
//  Created by Suman Raj on 13/06/14.
//  Copyright (c) 2014 Suman Raj. All rights reserved.
//

import XCTest
import UIKit
import SRWebClient

class SRWebClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func waitFor (inout wait: Bool) {
        while (wait) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
        }
    }
    
    func testPostImageSuccess() {
        var wait: Bool = true
        var image:UIImage = UIImage(contentsOfFile:"<PROVIDE_ABSOLUTE_PATH>/Swift-SRWebClient/SRWebClientTests/success.jpeg")!
        let imageData:NSData = NSData(data: UIImageJPEGRepresentation(image, 1.0))
        SRWebClient.POST("http://www.tiikoni.com/tis/upload/upload.php")
            .data(imageData, fieldName:"file", data:["days":"1","title":"Swift-SRWebClient","caption":"Uploaded via Swift-SRWebClient (https://github.com/sraj/Swift-SRWebClient)"])
            .send({(response:AnyObject!, status:Int) -> Void in
                //This will produce html document, look for "It can be viewed using this URL:",
                //it will be something like http://www.tiikoni.com/tis/view/?id=362c1d8
                println("response:\(response)")
                XCTAssertNotNil(response)
                wait = false
            },failure:{(error:NSError!) -> Void in
                println("failure")
                XCTAssertNil(error)
                wait = false
            })
        self.waitFor(&wait)
    }
    
    func testGetSuccess() {
        var wait: Bool = true
        SRWebClient.GET("http://headers.jsontest.com/",
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testGetDataSuccess() {
        var wait: Bool = true
        SRWebClient.GET("http://ip.jsontest.com/", data: ["q":"search"],
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testGetDataFuncChainSuccess() {
        var wait: Bool = true
        SRWebClient.GET("http://ip.jsontest.com/")
            .data(["q":"search"])
            .send({(response:AnyObject!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNil(error)
                wait = false
            })
        self.waitFor(&wait)
    }
    
    func testGetFailure() {
        var wait: Bool = true
        SRWebClient.GET("http://failure.example.com/",
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNotNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testGetDataFailure() {
        var wait: Bool = true
        SRWebClient.GET("http://failure.example.com/", data: ["q":"search"],
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNotNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testPostSuccess() {
        var wait: Bool = true
        let jsonData = NSJSONSerialization.dataWithJSONObject(["1","2","3"], options: nil, error: nil)
        let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
        SRWebClient.POST("http://validate.jsontest.com/", data: ["json" : jsonString!],
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testPostHeaderSuccess() {
        var wait: Bool = true
        let jsonData = NSJSONSerialization.dataWithJSONObject(["1","2","3"], options: nil, error: nil)
        let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
        SRWebClient.POST("http://validate.jsontest.com/", data: ["json":jsonString!],
            headers:["Content-Type":"application/x-www-form-urlencoded charset=utf-8"],
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testPostFailure() {
        var wait: Bool = true
        SRWebClient.POST("http://failure.example.com/",
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNotNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testPostDataFailure() {
        var wait: Bool = true
        SRWebClient.POST("http://failure.example.com/", data: ["data1":"example","data2":"example"],
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNil(response)
                wait = false
            },
            failure:{(error:NSError!) -> Void in
                XCTAssertNotNil(error)
                wait = false
        })
        self.waitFor(&wait)        
    }
    
    func testNilSuccessGet() {
        var wait: Bool = true
        SRWebClient.GET("http://headers.jsontest.com/",
            success:{(response:AnyObject!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            }, failure:nil)
        self.waitFor(&wait)
    }
    
    func testNilFailureGet() {
        var wait: Bool = true
        SRWebClient.GET("http://failure.example.com/",
            success:nil, failure:{(error:NSError!) -> Void in
                XCTAssertNotNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testNilPost() {
        SRWebClient.POST("http://failure.example.com/", data: nil, success:nil, failure:nil)
    }
}
