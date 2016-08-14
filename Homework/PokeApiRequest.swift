
import Unbox
import Foundation
import Alamofire

typealias UserConsumer = User -> ()

protocol Chainable {
    func ifSuccessfulDo() -> Self
    func ifFailedDo() -> Self
}

class ApiRequest<T: Unboxable> {
    
    typealias TConsumer = T -> ()
    typealias FailureRunnable = () -> ()
    
    private var successCallbackConsumer: TConsumer
    private var failureCallback: FailureRunnable
    
    init() {
        self.successCallbackConsumer = { _ in }
        self.failureCallback = {}
    }
    
    func ifSuccessfulDo(successCallbackConsumer: TConsumer) -> ApiRequest<T> {
        self.successCallbackConsumer = successCallbackConsumer
        return self
    }
    
    func ifFailedDo(failureCallback: FailureRunnable) -> ApiRequest<T> {
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
            .ifSuccessfulDo({
                let data: T = try Unbox($0) as T
                success(data)
                // self.successCallbackConsumer(data)
            }).ifFailedDo({ _ in
                failure()
                //self.failureCallback()
            })
    }
    
}

class ApiLoginRequest: PokeApiRequest<User> {
    
    override func ifSuccessfulDo(successCallbackConsumer: TConsumer) -> ApiLoginRequest {
        self.successCallbackConsumer = successCallbackConsumer
        return self
    }
    
    override func ifFailedDo(failureCallback: FailureRunnable) -> ApiLoginRequest {
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






