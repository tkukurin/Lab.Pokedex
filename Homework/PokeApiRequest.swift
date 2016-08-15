
import Unbox
import Foundation
import Alamofire

typealias UserConsumer = User -> ()

protocol Chainable {
    associatedtype ValueObject
    
    func ifPresent(successCallbackConsumer: ValueObject -> ()) -> Self
    func orElseDo(failureCallback: () -> ()) -> Self
}

class ApiRequest<T: Unboxable>: Chainable {
    typealias ValueObject = T
    
    typealias TConsumer = ValueObject -> ()
    typealias FailureRunnable = () -> ()
    
    private var successCallbackConsumer: TConsumer
    private var failureCallback: FailureRunnable
    
    init() {
        self.successCallbackConsumer = { _ in }
        self.failureCallback = {}
    }
    
    func ifPresent(successCallbackConsumer: TConsumer) -> Self {
        self.successCallbackConsumer = successCallbackConsumer
        return self
    }
    
    func orElseDo(failureCallback: FailureRunnable) -> Self{
        self.failureCallback = failureCallback
        return self
    }
    
}

class PokeApiRequest<T: Unboxable>: ApiRequest<T> {
    
    var serverRequestor: ServerRequestor
    
    override init() {
        self.serverRequestor = Container.sharedInstance.getServerRequestor()
        super.init()
    }
    
    private func deserialize(response: ServerResponse<AnyObject>,
                             type: T.Type,
                             success: TConsumer,
                             failure: FailureRunnable) {
        response
            .ifPresent({
                let data: T = try Unbox($0) as T
                success(data)
                // self.successCallbackConsumer(data)
            }).orElseDo({ _ in
                failure()
                //self.failureCallback()
            })
    }
    
}

class ApiLoginRequest: PokeApiRequest<User> {
    
    override func ifPresent(successCallbackConsumer: TConsumer) -> ApiLoginRequest {
        self.successCallbackConsumer = successCallbackConsumer
        return self
    }
    
    override func orElseDo(failureCallback: FailureRunnable) -> ApiLoginRequest {
        self.failureCallback = failureCallback
        return self
    }
    
    func doLogin(userLoginData: UserLoginData,
                 success: TConsumer,
                 failure: FailureRunnable) -> Request {
        let json = JsonMapBuilder.buildLoginRequest(userLoginData)
        return serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: json,
                               callback: { self.deserialize($0,
                                                type:User.self,
                                                success: success,
                                                failure: failure) })
    }
    
}






