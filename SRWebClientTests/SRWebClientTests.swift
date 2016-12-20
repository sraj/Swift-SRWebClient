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
    
    func waitFor (_ wait: inout Bool) {
        while (wait) {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1))
        }
    }
    
    func testPostImageSuccess() {
        var wait: Bool = true
        let image:UIImage = UIImage(contentsOfFile:"/Users/suman/Projects/iOS/Swift-SRWebClient/SRWebClientTests/success.jpeg")!
        let imageData:Data = NSData(data: UIImageJPEGRepresentation(image, 1.0)!) as Data
        _ = SRWebClient.POST("http://www.tiikoni.com/tis/upload/upload.php")
            .data(imageData, fieldName:"file", data:["days":"1","title":"Swift-SRWebClient","caption":"Uploaded via Swift-SRWebClient (https://github.com/sraj/Swift-SRWebClient)"])
            .send({(response:Any!, status:Int) -> Void in
                //This will produce html document, look for "It can be viewed using this URL:",
                //it will be something like http://www.tiikoni.com/tis/view/?id=362c1d8
                print("response:\(response)")
                XCTAssertNotNil(response)
                wait = false
            },failure:{(error:NSError!) -> Void in
                print("failure")
                XCTAssertNil(error)
                wait = false
            })
        self.waitFor(&wait)
    }
    
    func testGetSuccess() {
        var wait: Bool = true
        _ = SRWebClient.GET("http://headers.jsontest.com/",
            success:{(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.GET("http://ip.jsontest.com/", data: ["q":"search"],
            success:{(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.GET("http://ip.jsontest.com/")
            .data(["q":"search"])
            .send({(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.GET("http://failure.example.com/",
            success:{(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.GET("http://failure.example.com/", data: ["q":"search"],
            success:{(response:Any!, status:Int) -> Void in
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
        let jsonData = try? JSONSerialization.data(withJSONObject: ["1","2","3"], options: [])
        let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue)
        _ = SRWebClient.POST("http://validate.jsontest.com/", data: ["json" : jsonString!],
            success:{(response:Any!, status:Int) -> Void in
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
        let jsonData = try? JSONSerialization.data(withJSONObject: ["1","2","3"], options: [])
        let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue)
        _ = SRWebClient.POST("http://validate.jsontest.com/", data: ["json":jsonString!],
            headers:["Content-Type":"application/x-www-form-urlencoded charset=utf-8"],
            success:{(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.POST("http://failure.example.com/",
            success:{(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.POST("http://failure.example.com/", data: ["data1":"example","data2":"example"],
            success:{(response:Any!, status:Int) -> Void in
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
        _ = SRWebClient.GET("http://headers.jsontest.com/",
            success:{(response:Any!, status:Int) -> Void in
                XCTAssertNotNil(response)
                wait = false
            }, failure:nil)
        self.waitFor(&wait)
    }
    
    func testNilFailureGet() {
        var wait: Bool = true
        _ = SRWebClient.GET("http://failure.example.com/",
            success:nil, failure:{(error:NSError!) -> Void in
                XCTAssertNotNil(error)
                wait = false
        })
        self.waitFor(&wait)
    }
    
    func testNilPost() {
        _ = SRWebClient.POST("http://failure.example.com/", data: nil, success:nil, failure:nil)
    }
}
