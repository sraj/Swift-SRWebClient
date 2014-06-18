# Swift-SRWebClient

A super simple http client framework for iOS and OSX in Swift. 

## Features

1. Success and Failure closure blocks for easy callbacks.

2. NSOperationQueue and NSBlockOperation to execute web requests, using which we can have a elegant way to set queuePriority, threadPriority, qualityOfService and cancel any particular Operation or all the Operations in OperationQueue.

3. Provides function to send Image/`multipart/form-data` data.

4. Function chaining provides us to chain methods and provides more expressive code to make web requests.

5. Json deserialize, when any response is a valid JSON object, otherwise return the actaul response data as string.

6. Headers, Timeout Interval can be set and controlled for each request.

7. Test cases for all the functionalities

### Success and Failure Closures

```swift
SRWebClient.GET("http://headers.jsontest.com/", 
	success:{(response:AnyObject!, status:Int) -> Void in 
		//process success response
	}, failure:{(error:NSError!) -> Void in 
		//process failure response
	})
```

### NSBlockOperation

```swift
var webClient = SRWebClient(method: "POST", url:"http://validate.jsontest.com/")
webClient.timeoutInterval = 30.0
webClient.priority = NSOperationQueuePriority.High
webClient.send({(response:AnyObject!, status:Int) -> Void in
		//process success response
	}, failure:{(error:NSError!) -> Void in
        //process failure response        
	})
```

### Image Upload

```swift
var image:UIImage = UIImage(named: "apple.jpeg")
let imageData:NSData = NSData.dataWithData(UIImageJPEGRepresentation(image, 1.0))
SRWebClient.POST("http://www.tiikoni.com/tis/upload/upload.php")
	.data(imageData, fieldName:"file", data:["days":"1","title":"Swift-SRWebClient","caption":"Uploaded via Swift-SRWebClient (https://github.com/sraj/Swift-SRWebClient)"])
	.send({(response:AnyObject!, status:Int) -> Void in
		//process success response
	},failure:{(error:NSError!) -> Void in
		//process failure response
	})
```

### Function chaining

```swift
SRWebClient.POST("http://validate.jsontest.com")
	.headers(["Content-Type":"application/x-www-form-urlencoded charset=utf-8"])
	.data(["json":"[1, 2, 3]"])
	.send({(response:AnyObject!, status:Int) -> Void in
        	//process success response	        
		}, failure:{(error:NSError!) -> Void in
        	//process failure response    
		})
```

### JSON Deserialize

```swift
SRWebClient.GET("http://headers.jsontest.com/", 
	success:{(response:AnyObject!, status:Int) -> Void in 
		let headersJSON = response! as Dictionary<String, String>
		println(headersJSON["key"]!)
	}, failure:{(error:NSError!) -> Void in 
		println(error!.code)
	})
```

### Timeout Interval

```swift
var webClient = SRWebClient(method: "POST", url:"http://validate.jsontest.com/")
webClient.timeoutInterval = 60.0
webClient.headers(["key":"value"])
	.send({(response:AnyObject!, status:Int) -> Void in
        //process success response
	}, failure:{(error:NSError!) -> Void in
        //process failure response
	})
```

## TODO

- Retry mechanisam when a request fails.
- Provide a more elegant way to cancel/suspend each operation.
- Image download
- Any features requested.

Contribution welcome!

## License

```
The MIT License (MIT)

Copyright © 2014 Suman Raj Venkatesan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
````

## Acknowledgment

Some API names are similar to [Agent](https://github.com/hallas/agent) Framework. Licensed under MIT. Thanks to Christoffer Hallas for his contribution.