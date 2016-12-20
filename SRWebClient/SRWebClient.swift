//
//  SRWebClient.swift
//  SRWebClient
//
//  Created by Suman Raj on 07/06/14.
//  Copyright (c) 2014 Suman Raj. All rights reserved.
//

import Foundation

public class SRWebClient : NSObject
{
    public typealias Headers = Dictionary<String, String>
    public typealias RequestData = Dictionary<String,Any>
    public typealias SuccessHandler = (Any?, Int) -> Void
    public typealias FailureHandler = (NSError!) -> Void
    
    var operationQueue: OperationQueue
    var urlRequest: NSMutableURLRequest? = nil
    var priority:Operation.QueuePriority = Operation.QueuePriority.normal
    var timeoutInterval:TimeInterval = 30.0
    
    struct HeaderConstants {
        static var CONTENT_TYPE = "Content-Type"
    }
    
    struct MimeConstants {
        static var APPLICATION_JSON = "application/json"
    }
    
    /**
    *  GET class methods
    */
    public class func GET(_ url: String) -> SRWebClient {
        return SRWebClient(method: "GET", url: url)
    }
    
    public class func GET(_ url: String, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.GET(url).send(success, failure: failure)
    }
    
    public class func GET(_ url: String, data:RequestData?, headers:Headers?) -> SRWebClient {
        return SRWebClient.GET(url).headers(headers).data(data)
    }
    
    public class func GET(_ url: String, data:RequestData?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.GET(url, data: data, headers:nil).send(success, failure: failure)
    }
    
    public class func GET(_ url: String, data:RequestData?, headers:Headers?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.GET(url, data: data, headers:headers).send(success, failure: failure)
    }
    
    /**
    *  POST class methods
    */
    public class func POST(_ url: String) -> SRWebClient {
        return SRWebClient(method: "POST", url: url)
    }
    
    public class func POST(_ url: String, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.POST(url).send(success, failure: failure)
    }
    
    public class func POST(_ url: String, data:RequestData?, headers:Headers?) -> SRWebClient {
        return SRWebClient.POST(url).headers(headers).data(data)
    }
    
    public class func POST(_ url: String, data:RequestData?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.POST(url, data: data, headers:nil).send(success, failure: failure)
    }
    
    public class func POST(_ url: String, data:RequestData?, headers:Headers?, success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        return SRWebClient.POST(url, data: data, headers:headers).send(success, failure: failure)
    }
    
    /**
    *  Instance initialization
    */
    init(method:String, url:String) {
        self.operationQueue = OperationQueue()
        self.urlRequest = NSMutableURLRequest(url: URL(string: url)!)
        self.urlRequest!.httpMethod = method
        self.urlRequest!.timeoutInterval = timeoutInterval
    }
    
    /**
    *  Function to set headers
    *
    *  @param Headers? optional value of type Dictionary<String, String>
    *
    *  @return self instance to support function chaining
    */
    public func headers(_ headers: Headers?) -> SRWebClient {
        if (headers != nil) {
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
    func build(_ dataDict:RequestData?) -> String? {
        var dataList: [String] = [String]()
        if(dataDict != nil) {
            for (key, value) in dataDict! {
                dataList.append("\(key)=\(value)")
            }
        }
        return dataList.joined(separator: "&").addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
    }
    
    /**
    *  Function to set data for POST/GET request
    *
    *  @param data:RequestData? optional value of type Dictionary<String,AnyObject>
    *
    *  @return self instance to support function chaining
    */
    public func data(_ data:RequestData?) -> SRWebClient {
        if(data != nil && data!.count > 0) {
            switch self.urlRequest!.httpMethod {
            case "GET":
                let url:String = self.urlRequest!.url!.absoluteString
                self.urlRequest!.url = URL(string: url + "?" + self.build(data)!)
            case "POST":
                self.urlRequest!.httpBody  = self.build(data)!.data(using: String.Encoding.utf8, allowLossyConversion: true)
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
    open func data(_ image:Data, fieldName:String, data:RequestData?) -> SRWebClient {
        if(image.count > 0 && self.urlRequest!.httpMethod == "POST") {
            
            let uniqueId = ProcessInfo.processInfo.globallyUniqueString
            
            let postBody:NSMutableData = NSMutableData()
            var postData:String = String()
            let boundary:String = "------WebKitFormBoundary\(uniqueId)"
            
            self.urlRequest?.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField:"Content-Type")
            
            if(data != nil && data!.count > 0) {
                postData += "--\(boundary)\r\n"
                for (key, value) in data! {
                    if let value = value as? String {
                        postData += "--\(boundary)\r\n"
                        postData += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                        postData += "\(value)\r\n"
                    }
                }
            }
            postData += "--\(boundary)\r\n"
            postData += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(Int64(Date().timeIntervalSince1970*1000)).jpg\"\r\n"
            postData += "Content-Type: image/jpeg\r\n\r\n"
            postBody.append(postData.data(using: String.Encoding.utf8)!)
            postBody.append(image)
            postData = String()
            postData += "\r\n"
            postData += "\r\n--\(boundary)--\r\n"
            postBody.append(postData.data(using: String.Encoding.utf8)!)
            
            self.urlRequest!.httpBody = NSData(data: postBody as Data) as Data
        }
        return self
    }
    
    /**
    *  Function to cancel request operation
    */
    open func cancel() {
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
    open func send(_ success:SuccessHandler?, failure:FailureHandler?) -> SRWebClient {
        let blockOperation:BlockOperation = BlockOperation(block: {() -> Void in
            
            var response:URLResponse?
            var error:NSError?
            
            let result:Data?
            do {
                result = try NSURLConnection.sendSynchronousRequest(self.urlRequest! as URLRequest, returning: &response)
            } catch let error1 as NSError {
                error = error1
                result = nil
            } catch {
                fatalError()
            }
            let httpResponse:HTTPURLResponse? = response as? HTTPURLResponse
            
            OperationQueue.main.addOperation({() -> Void in
                if (httpResponse != nil && httpResponse!.statusCode >= 200 && httpResponse!.statusCode <= 300) {
                    let respHeaders = httpResponse!.allHeaderFields as! Dictionary<String,String>
                    if respHeaders[HeaderConstants.CONTENT_TYPE] == MimeConstants.APPLICATION_JSON {
                        let json:Any?
                        do {
                            json = try JSONSerialization.jsonObject(with: result!, options: [])
                        } catch let error1 as NSError {
                            error = error1
                            json = nil
                        } catch {
                            fatalError()
                        }
                        if (error != nil && failure != nil) {
                            failure!(error)
                        } else if (json != nil && success != nil) {
                            success!(json, httpResponse!.statusCode)
                        }
                    } else if (success != nil) {
                        success!(NSString(data: result!, encoding: String.Encoding.utf8.rawValue), httpResponse!.statusCode)
                    }
                } else if (response != nil && httpResponse != nil && failure != nil) {
                    failure!(NSError(domain: self.urlRequest!.url!.path, code: httpResponse!.statusCode, userInfo: nil))
                } else if (failure != nil) {
                    failure!(error)
                }
            })
        })
        
        blockOperation.queuePriority = self.priority
        self.operationQueue.addOperation(blockOperation)
        return self
    }
}
