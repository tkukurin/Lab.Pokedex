
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
        
        self.serverRequestor =  Container.sharedInstance.getServerRequestor()
    }
    
}

class PokeApiJsonRequest<T: Unboxable>: ApiRequest<T> {
    
    init() {
        super.init()
    }
    
    private func deserialize(response: ServerResponse<AnyObject>) {
        response
            .ifPresent({
                let data: T = try Unbox($0) as T
                self.successCallbackConsumer(data)
            }).orElseDo({ _ in
                self.failureCallback()
            })
    }
    
}

class ApiLoginRequest: PokeApiJsonRequest<User> {
    
    func doLogin(userLoginData: UserLoginData) -> Request {
        let json = JsonMapBuilder.buildLoginRequest(userLoginData)
        return serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: json,
                               callback: deserialize)
    }
    
}

class ApiRegisterRequest: PokeApiJsonRequest<User> {
    
    func doRegister(userRegisterData: UserRegisterData) -> Request {
        let json = JsonMapBuilder.buildRegisterRequest(userRegisterData)
        return serverRequestor.doPost(RequestEndpoint.USER_ACTION_CREATE_OR_DELETE,
                                      jsonReq: json,
                                      callback: deserialize)
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

class ApiCommentRequest: PokeApiJsonRequest<CommentList> {
    func doGetComments(requestingUser: User, pokemonId: Int) -> Request {
        return serverRequestor.doGet(RequestEndpoint.forComments(pokemonId),
                              requestingUser: requestingUser,
                              callback: deserialize)
    }
}

class ApiPhotoRequest: ApiRequest<UIImage?> {
    
    init() {
        super.init()
    }
    
    func doGetPhoto(imageUrl: String) {
        AsyncImageLoader().loadFrom(RequestEndpoint.forImages(imageUrl),
                                    callback: self.successCallbackConsumer)
    }
    
}




