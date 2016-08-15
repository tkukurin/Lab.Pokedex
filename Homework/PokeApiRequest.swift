
import Unbox
import Foundation
import Alamofire

protocol ChainableApiCallback: class {
    associatedtype ValueObject
    
    var successCallbackConsumer: ValueObject -> () { get set }
    var failureCallback: () -> () { get set }
}

extension ChainableApiCallback {
    func setSuccessHandler(successCallbackConsumer: ValueObject -> ()) -> Self {
        self.successCallbackConsumer = successCallbackConsumer
        return self
    }
    
    func setFailureHandler(failureCallback: () -> ()) -> Self {
        self.failureCallback = failureCallback
        return self
    }
}

class ApiRequest<T>: ChainableApiCallback {
    typealias ValueObject = T
    
    typealias SuccessResultConsumer = ValueObject -> ()
    typealias FailureRunnable = () -> ()
    
    var successCallbackConsumer: SuccessResultConsumer
    var failureCallback: FailureRunnable
    
    var serverRequestor: ServerRequestor
    
    init(onSuccess: SuccessResultConsumer = {_ in }, onFailure: FailureRunnable = {}) {
        self.successCallbackConsumer = onSuccess
        self.failureCallback = onFailure
        
        self.serverRequestor =  Container.sharedInstance.get(ServerRequestor.self)
    }
}

class PokeApiJsonRequest<T: Unboxable>: ApiRequest<T> {
    
    init() {
        super.init()
    }
    
    private func deserialize(data: NSData?) {
        Result.ofNullable(data)
            .flatMap({ Result.ofNullable(try? Unbox($0) as T) })
            .ifPresent(successCallbackConsumer)
            .orElseDo({ self.failureCallback() })
    }
    
}

class ApiUserRequest: PokeApiJsonRequest<User> {
    
    func doLogin(userLoginData: UserLoginData) -> Request {
        let json = JsonMapBuilder.buildLoginRequest(userLoginData)
        
        return serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: json,
                               callback: deserialize)
    }
    
    func doRegister(userRegisterData: UserRegisterData) -> Request {
        let json = JsonMapBuilder.buildRegisterRequest(userRegisterData)
        return serverRequestor.doPost(RequestEndpoint.USER_ACTION_CREATE_OR_DELETE,
                                      jsonReq: json,
                                      callback: deserialize)
    }
    
    func doGet(requestingUser: User, userId: String) -> Request {
        return serverRequestor.doGet(RequestEndpoint.forUsers(userId),
                              requestingUser: requestingUser,
                              callback: deserialize)
    }
    
    func doLogout(user: User) -> Request {
        return serverRequestor.doDelete(RequestEndpoint.USER_ACTION_LOGOUT,
                                        user: user)
    }
    
}

class ApiPokemonListRequest: PokeApiJsonRequest<PokemonList> {
    func doGetPokemons(requestingUser: User) -> Request {
        return serverRequestor.doGet(
            RequestEndpoint.POKEMON_ACTION,
            requestingUser: requestingUser,
            callback: deserialize)
    }
}

class ApiCommentListRequest: PokeApiJsonRequest<CommentList> {
    func doGetComments(requestingUser: User, pokemonId: Int) -> Request {
        return serverRequestor.doGet(RequestEndpoint.forComments(pokemonId),
                              requestingUser: requestingUser,
                              callback: deserialize)
    }
}

class ApiCommentPostRequest: PokeApiJsonRequest<CommentCreatedResponse> {
    func doPostComment(requestingUser: User, pokemonId: Int, content: String) {
        serverRequestor.doMultipart(RequestEndpoint.forComments(pokemonId),
                                           user: requestingUser,
                                           attributes: [ApiRequestConstants.Comment.CONTENT: content],
                                           callback: deserialize)
    }
}

class ApiPokemonCreateRequest: PokeApiJsonRequest<PokemonCreatedResponse> {
    func doCreate(requestingUser: User, image: UIImage?, attributes: [String:String]) {
        serverRequestor.doMultipart(RequestEndpoint.POKEMON_ACTION,
                                    user: requestingUser,
                                    pickedImage: image,
                                    attributes: attributes,
                                    callback: deserialize)
    }
}

class ApiPhotoRequest: ApiRequest<UIImage> {
    
    private var request: Request?
    
    init() {
        super.init()
    }
    
    func prepareRequest(imageUrl: String) -> ApiPhotoRequest {
        request = serverRequestor
            .requestManager
            .request(.GET, RequestEndpoint.resolveFullUrl(RequestEndpoint.forImages(imageUrl)))
        return self
    }
    
    func getRequest() -> Request {
        return self.request!
    }
    
    func doGetPhoto() -> Request? {
        request?.validate()
            .response(completionHandler: { (_, _, data, error) in
                if error != nil {
                    self.failureCallback()
                } else {
                    Result
                        .ofNullable(data)
                        .flatMap({ Result.ofNullable(UIImage(data: $0)) })
                        .ifPresent(self.successCallbackConsumer)
                        .orElseDo(self.failureCallback)
                }
            })
        
        return request
    }
    
}




