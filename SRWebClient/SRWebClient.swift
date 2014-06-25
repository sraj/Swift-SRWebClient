//
//  SRWebClient.swift
//  SRWebClient
//
//  Created by Suman Raj on 07/06/14.
//  Copyright (c) 2014 Suman Raj. All rights reserved.
//

import Foundation

class SRWebClient : NSObject
{
    typealias Headers = Dictionary<String, String>
    typealias RequestData = Dictionary<String,AnyObject>
    typealias SuccessHandler = (AnyObject!, Int) -> Void
    typealias FailureHandler = (NSError!) -> Void
    
    var operationQueue: NSOperationQueue
    var urlRequest: NSMutableURLRequest? = nil
    var priority:NSOperationQueuePriority = NSOperationQueuePriority.Normal
    var timeoutInterval:NSTimeInterval = 30.0
    
    struct HeaderConstants {
        static var CONTENT_TYPE:String = "Content-Type"
    }
    
    struct MimeConstants {
        static var APPLICATION_JSON = "application/json"
    }
    
    /**
    *  GET class methods
    */
    class func GET(url: String) -> SRWebClient {
        return SRWebClient(method: "GET", url: url)
    }
    
    class func GET(url: String, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.GET(url).send(success, failure)
    }
    
    class func GET(url: String, data:RequestData?, headers:Headers?) -> SRWebClient {
        return SRWebClient.GET(url).headers(headers).data(data)
    }
    
    class func GET(url: String, data:RequestData?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.GET(url, data: data, headers:nil).send(success, failure)
    }
    
    class func GET(url: String, data:RequestData?, headers:Headers?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.GET(url, data: data, headers:headers).send(success, failure)
    }
    
    /**
    *  POST class methods
    */
    class func POST(url: String) -> SRWebClient {
        return SRWebClient(method: "POST", url: url)
    }
    
    class func POST(url: String, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.POST(url).send(success, failure)
    }
    
    class func POST(url: String, data:RequestData?, headers:Headers?) -> SRWebClient {
        return SRWebClient.POST(url).headers(headers).data(data)
    }
    
    class func POST(url: String, data:RequestData?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.POST(url, data: data, headers:nil).send(success, failure)
    }
    
    class func POST(url: String, data:RequestData?, headers:Headers?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.POST(url, data: data, headers:headers).send(success, failure)
    }
    
    /**
    *  Instance initialization
    */
    init(method:String, url:String) {
        self.operationQueue = NSOperationQueue()
        self.urlRequest = NSMutableURLRequest(URL: NSURL(string: url))
        self.urlRequest!.HTTPMethod = method
        self.urlRequest!.timeoutInterval = timeoutInterval
    }
    
    /**
    *  Function to set headers
    *
    *  @param Headers? optional value of type Dictionary<String, String>
    *
    *  @return self instance to support function chaining
    */
    func headers(headers: Headers?) -> SRWebClient {
        if (headers) {
            self.urlRequest!.allHTTPHeaderFields = headers!
        }
        return self
    }
    
    /**
    *  Function to build GET/POST request data E.g., a dictionary of ["a":"b","c":"d"] will return "a=b&c=d"
    *
    *  @param dataDict:RequestData? request data
    *
    *  @return of type String
    */
    func build(dataDict:RequestData?) -> String? {
        var dataList: String[] = String[]()
        if(dataDict) {
            for (key, value : AnyObject) in dataDict! {
                dataList.append("\(key)=\(value)")
            }
        }
        return join("&", dataList).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }
    
    /**
    *  Function to set data for POST/GET request
    *
    *  @param data:RequestData? optional value of type Dictionary<String,AnyObject>
    *
    *  @return self instance to support function chaining
    */
    func data(data:RequestData?) -> SRWebClient {
        if(data && data!.count > 0) {
            switch self.urlRequest!.HTTPMethod! {
                case "GET":
                    let url:String = self.urlRequest!.URL!.absoluteString
                    self.urlRequest!.URL = NSURL(string: url + "?" + self.build(data)!)
                case "POST":
                    self.urlRequest!.HTTPBody  = self.build(data)!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                default:
                    break
            }
        }
        return self
    }
    
    /**
    *  Function to upload image & data using POST request
    *
    *  @param image:NSData       image data of type NSData
    *  @param fieldName:String   field name for uploading image
    *  @param data:RequestData?  optional value of type Dictionary<String,AnyObject>
    *
    *  @return self instance to support function chaining
    */
    func data(image:NSData, fieldName:String, data:RequestData?) -> SRWebClient {
        if(image.length > 0 && self.urlRequest!.HTTPMethod! == "POST") {
            
            let uniqueId = NSProcessInfo.processInfo()!.globallyUniqueString
            
            var postBody:NSMutableData = NSMutableData()
            var postData:String = String()
            var boundary:String = "------WebKitFormBoundary\(uniqueId)"
            
            self.urlRequest?.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField:"Content-Type")
            
            if(data && data!.count > 0) {
                postData += "--\(boundary)\r\n"
                for (key, value : AnyObject) in data! {
                    if let value = value as? String {
                        postData += "--\(boundary)\r\n"
                        postData += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                        postData += "\(value)\r\n"
                    }
                }
            }
            postData += "--\(boundary)\r\n"
            postData += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(Int(NSDate().timeIntervalSince1970*1000)).png\"\r\n"
            postData += "Content-Type: image/png\r\n\r\n"
            postBody.appendData(postData.dataUsingEncoding(NSUTF8StringEncoding))
            postBody.appendData(image)
            postData = String()
            postData += "\r\n"
            postData += "\r\n--\(boundary)--\r\n"
            postBody.appendData(postData.dataUsingEncoding(NSUTF8StringEncoding))
            
            self.urlRequest!.HTTPBody = NSData(data: postBody)
        }
        return self
    }
    
    /**
    *  Function to cancel request operation
    */
    func cancel() {
        if(self.operationQueue.operationCount > 0) {
            self.operationQueue.cancelAllOperations()
        }
    }
    
    /**
    *  Function to send request to endpoint url, creates NSBlockOperation and add it to NSOperationQueue to execture the task
    *  and calls the respective handlers when ever we get data or failure.
    *
    *  @param successHandler:SuccessHandler? block of type (AnyObject!, Int) -> Void
    *  @param failureHandler:FailureHandler? block of type (NSError!) -> Void
    *
    *  @return self instance to support function chaining
    */
    func send(success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        var blockOperation:NSBlockOperation = NSBlockOperation({() -> Void in
            
            var response:NSURLResponse?
            var error:NSError?
            
            let result:NSData? = NSURLConnection.sendSynchronousRequest(self.urlRequest, returningResponse: &response, error: &error)
            let httpResponse:NSHTTPURLResponse? = response as? NSHTTPURLResponse
            
            NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                if(response && httpResponse!.statusCode >= 200 && httpResponse!.statusCode <= 300) {
                    if(httpResponse!.allHeaderFields[HeaderConstants.CONTENT_TYPE].containsString(MimeConstants.APPLICATION_JSON)) {
                        let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(result, options: nil, error: &error)
                        if (error && failure) {
                            failure!(error)
                        } else if (json && success) {
                            success!(json, httpResponse!.statusCode)
                        }
                    } else if (success) {
                        success!(NSString(data: result, encoding: NSUTF8StringEncoding), httpResponse!.statusCode)
                    }
                } else if (response && httpResponse && failure) {
                    failure!(NSError(domain: self.urlRequest!.URL.path, code: httpResponse!.statusCode, userInfo: nil))
                } else if (failure) {
                    failure!(error)
                }
            })
        })
        
        blockOperation.queuePriority = self.priority
        self.operationQueue.addOperation(blockOperation)
        return self
    }
}