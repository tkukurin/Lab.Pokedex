import Alamofire

typealias ServerCallbackFn = ((response: ServerResponse<AnyObject>) -> Void)

class RequestEndpoint {
    static let USER_ACTION_CREATE_OR_DELETE = "api/v1/users"
    static let USER_ACTION_LOGIN = "api/v1/users/login"
    static let POKEMON_ACTION = "api/v1/pokemons"
    
    static func forComments(pokemonId: Int) -> String {
        return POKEMON_ACTION + "/\(pokemonId)/comments"
    }
    
    
    static func forUsers(userId: String) -> String {
        return USER_ACTION_CREATE_OR_DELETE + "/\(userId)"
    }
    
    static func forImages(imageUrl: String) -> String {
        let advance = min(imageUrl.characters.count, 1)
        return imageUrl.substringFromIndex(imageUrl.startIndex.advancedBy(advance))
    }
}

class ServerResponse<T> {
    let responseDelegate: Response<T, NSError>
    
    init(_ responseDelegate: Response<T, NSError>) {
        self.responseDelegate = responseDelegate
    }
    
    func ifPresent(consumer: (NSData throws -> ())) -> Result<Void> {
        switch responseDelegate.result {
        case .Success:
            do {
                try consumer(responseDelegate.data ?? NSData(contentsOfFile: "")!)
            } catch {
                return Result.error("\(error)")
            }
        case .Failure(let error):
            return Result.error(error.localizedDescription)
        }
        
        return Result.of()
    }
}

class ServerRequestor {
    static let REQUEST_DOMAIN = "https://pokeapi.infinum.co/"
    private static let COMPRESSION_QUALITY: CGFloat = 0.8

    func doGet(toEndpoint: String,
                      requestingUser: User? = nil,
                      callback: ServerCallbackFn) -> Request {
        let headers = Result
            .ofNullable(requestingUser)
            .map(headersForUser)
            .orElseGet({ [String:String]() })
        
        return Alamofire.request(.GET,
                          resolveUrl(toEndpoint),
                          headers: headers)
            .validate().responseJSON { response in
                callback(response: ServerResponse(response))
            }
    }

    func doPost(toEndpoint: String,
                   jsonReq: JsonType,
                   requestingUser: User? = nil,
                   callback: ServerCallbackFn) -> Request {
        let headers = Result
            .ofNullable(requestingUser)
            .map(headersForUser)
            .orElseGet({ [String:String]() })
        
        Alamofire.Manager.sharedInstance.session.configuration
            .HTTPAdditionalHeaders = headers
        
        return Alamofire.request(.POST,
                          resolveUrl(toEndpoint),
                          parameters: jsonReq,
                          encoding: .JSON)
            .validate().responseJSON { response in
                callback(response: ServerResponse(response))
            }
    }

    func doDelete(toEndpoint: String) {
        Alamofire.request(.DELETE,
                          resolveUrl(toEndpoint),
                          headers: [ "Content-type" : "text\\html" ])
    }

    func doMultipart(toEndpoint: String,
                            user: User,
                            pickedImage: UIImage? = nil,
                            attributes: [String: String],
                            callback: ServerResponse<String>? -> Void) {
        let headers = headersForUser(user)
        
        Alamofire.upload(.POST,
                         resolveUrl(toEndpoint),
                         headers: headers,
                         multipartFormData: { multipartFormData in
                            self.addImageMultipart(multipartFormData, pickedImage)
                            self.addAttributesMultipart(multipartFormData, attributes);
                        }, encodingCompletion: { encodingResult in
                            self.multipartEncodedCallback(encodingResult, delegateResultTo: callback)
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
    
    func multipartEncodedCallback(encodingResult: MultipartEncodingResult, delegateResultTo: ServerResponse<String>? -> Void) {
        switch encodingResult {
        case .Success(let upload, _, _):
            upload.responseString(completionHandler: { delegateResultTo(ServerResponse($0)) })
        default:
            delegateResultTo(nil)
        }
    }

    private func toMultipartAttributeName(key: String) -> String {
      return "data[attributes][\(key)]"
    }

    private func resolveUrl(endpoint: String) -> String {
      return ServerRequestor.REQUEST_DOMAIN + endpoint
    }

    private func headersForUser(user: User) -> [String:String] {
        return [ "Authorization": "Token token=\(user.attributes.authToken ?? ""), email=\(user.attributes.email)"]
    }

}