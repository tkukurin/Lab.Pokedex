import Alamofire

typealias ServerCallbackFn = ((response: ServerResponse<AnyObject>) -> Void)

class RequestEndpoint {
    static let USER_ACTION_CREATE_OR_DELETE = "users"
    static let USER_ACTION_LOGIN = "users/login"
    static let POKEMON_ACTION = "pokemons"
    
    static func forComments(pokemonId: Int) -> String {
        return POKEMON_ACTION + ":" + String(pokemonId) + "/comments"
    }
}

class ServerResponse<T> {
    let responseDelegate: Response<T, NSError>
    
    init(_ responseDelegate: Response<T, NSError>) {
        self.responseDelegate = responseDelegate
    }
    
    func ifSuccessfulDo(consumer: ((NSData) throws -> ())) -> Result<Void> {
        print(String(self.responseDelegate.data?.bytes) ?? "no data")
        switch responseDelegate.result {
        case .Success:
            do {
                try consumer(responseDelegate.data ?? NSData(contentsOfFile: "")!)
            } catch {
                return Result.error("\(error)")
            }
        case .Failure(let error):
            return Result.error("Error code: \(error.code)")
        }
        
        return Result.of()
    }
}

class ServerRequestor {
    static let REQUEST_DOMAIN = "https://pokeapi.infinum.co/"
    static let APIREQUEST_URL = "\(ServerRequestor.REQUEST_DOMAIN)api/v1/"

    private static let COMPRESSION_QUALITY: CGFloat = 0.8

    func doGet(toEndpoint: String,
                      requestingUser: User,
                      callback: ServerCallbackFn) {
        let headers = headersForUser(requestingUser)
        Alamofire.request(.GET,
                          resolveUrl(toEndpoint),
                          headers: headers)
            .validate().responseJSON { response in
                callback(response: ServerResponse(response))
            }
    }

    func doPost(toEndpoint: String,
                   jsonReq: JsonType,
                   callback: ServerCallbackFn) {
        Alamofire.request(.POST,
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
                            pickedImage: UIImage?,
                            attributes: [String: String],
                            callback: (MultipartEncodingResult -> Void)) {
        let headers = headersForUser(user)
        Alamofire.upload(.POST,
                         resolveUrl(toEndpoint),
                         headers: headers,
                         multipartFormData: { multipartFormData in
                            self.addImageMultipart(multipartFormData, pickedImage)
                            self.addAttributesMultipart(multipartFormData, attributes);
                        }, encodingCompletion: { encodingResult in
                            callback(encodingResult)
                        })
    }

    private func addImageMultipart(multipartFormData: MultipartFormData,
                                   _ pickedImage: UIImage?) {
        pickedImage.flatMap({ UIImageJPEGRepresentation($0, ServerRequestor.COMPRESSION_QUALITY) })
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

    private func resolveUrl(endpoint: String) -> String {
      return ServerRequestor.APIREQUEST_URL + endpoint
    }

    private func headersForUser(user: User) -> [String:String] {
        return [ "Authorization": "Token token=\(user.attributes.authToken), email=\(user.attributes.email)"]
    }

}