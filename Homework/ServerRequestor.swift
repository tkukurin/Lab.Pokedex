import Alamofire

class ServerRequestor {
    typealias NSDataServerResponseConsumer = NSData? -> ()
    
    private static let COMPRESSION_QUALITY: CGFloat = 0.8
    let requestManager: Manager
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // this was a nice idea but doesn't seem to work.
        // Expected behavior was for Alamofire to give up if it doesn't manage to
        // download file within X seconds (TBD during runtime).
        //configuration.timeoutIntervalForRequest = 10
        //configuration.timeoutIntervalForResource = 10
        
        self.requestManager = Alamofire.Manager(configuration: configuration)
    }

    func doGet(toEndpoint: String,
               requestingUser: User? = nil,
               callback: NSDataServerResponseConsumer) -> Request {
        let headers = headersForUser(requestingUser)
        
        return requestManager.request(.GET,
                          resolveUrl(toEndpoint),
                          headers: headers)
            .validate().responseJSON { response in
                callback(self.extractNSDataOrNilIfFailed(response))
            }
    }

    func doPost(toEndpoint: String,
                   jsonReq: JsonType,
                   requestingUser: User? = nil,
                   callback: NSDataServerResponseConsumer) -> Request {
        let headers = headersForUser(requestingUser)
        
        requestManager.session.configuration
            .HTTPAdditionalHeaders = headers
        
        return requestManager.request(.POST,
                          resolveUrl(toEndpoint),
                          parameters: jsonReq,
                          encoding: .JSON)
            .validate().responseJSON { response in
                callback(self.extractNSDataOrNilIfFailed(response))
            }
    }
    
    func extractNSDataOrNilIfFailed(response: Response<AnyObject, NSError>) -> NSData? {
        switch response.result {
        case .Success:
            if let data = response.data {
                return data
            }
        default: break
        }
        
        return nil
    }

    func doMultipart(toEndpoint: String,
                     user: User,
                     pickedImage: UIImage? = nil,
                     attributes: [String: String],
                     callback: NSDataServerResponseConsumer) {
        let headers = headersForUser(user)
        
        requestManager.upload(.POST,
                         resolveUrl(toEndpoint),
                         headers: headers,
                         multipartFormData: { multipartFormData in
                            self.addImageMultipart(multipartFormData, pickedImage)
                            self.addAttributesMultipart(multipartFormData, attributes);
                        }, encodingCompletion: { encodingResult in
                            self.sendNSDataFromMultipartRequestToCallbackOrNilIfFailed(encodingResult, delegateResultTo: callback)
                        })
    }

    private func addImageMultipart(multipartFormData: MultipartFormData,
                                   _ pickedImage: UIImage?) {
        let _ = pickedImage.flatMap({ UIImageJPEGRepresentation($0, ServerRequestor.COMPRESSION_QUALITY) })
                           .flatMap({ multipartFormData.appendBodyPart(
                                data: $0,
                                name: toMultipartAttributeName("image"),
                                fileName: "file.jpeg",
                                mimeType: "image/jpeg")
                            })
    }

    private func addAttributesMultipart(multipartFormData: MultipartFormData,
                                        _ attributes: [String: String]) {
        for (key, value) in attributes {
            multipartFormData.appendBodyPart(
                data: value.dataUsingEncoding(NSUTF8StringEncoding)!,
                name: toMultipartAttributeName(key))
        }
    }
    
    private func toMultipartAttributeName(key: String) -> String {
        return "data[attributes][\(key)]"
    }
    
    func sendNSDataFromMultipartRequestToCallbackOrNilIfFailed(
                                encodingResult: Alamofire.Manager.MultipartFormDataEncodingResult,
                                delegateResultTo: NSDataServerResponseConsumer) {
        switch encodingResult {
        case .Success(let upload, _, _):
            upload.responseString(completionHandler: { response in
                delegateResultTo(response.data)
            })
        default:
            delegateResultTo(nil)
        }
    }
    
    func doDelete(toEndpoint: String,
                  user: User) -> Request {
        return requestManager.request(.DELETE, resolveUrl(toEndpoint),
                                 headers: headersForUser(user))
    }

    private func resolveUrl(endpoint: String) -> String {
      return RequestEndpoint.resolveFullUrl(endpoint)
    }

    private func headersForUser(user: User?) -> [String:String] {
        return Result
            .ofNullable(user)
            .map({ [ "Authorization":
                     "Token token=\($0.attributes.authToken ?? ""), email=\($0.attributes.email)"] })
            .orElseGet({ [String:String]() })
    }

}