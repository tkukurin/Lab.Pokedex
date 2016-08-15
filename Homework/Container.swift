
import Foundation
import UIKit

//class Container {
//    static let sharedInstance = Container();
//    
//    private let localStorageAdapter: LocalStorageAdapter
//    private let imageLoader: UrlImageLoader
//    private let serverRequestor: ServerRequestor
//    
//    private init() {
//        localStorageAdapter = LocalStorageAdapter()
//        imageLoader = AsyncImageLoader()
//        serverRequestor = ServerRequestor()
//    }
//    
//    func getLocalStorageAdapter() -> LocalStorageAdapter {
//        return localStorageAdapter
//    }
//    
//    func getAlertUtilities(caller: UIViewController) -> AlertUtils {
//        return AlertUtils(caller)
//    }
//    
//    func getImageLoader() -> UrlImageLoader {
//        return imageLoader
//    }
//    
//    func get(ServerRequestor.self) -> ServerRequestor {
//        return serverRequestor
//    }
//    
//}

class Instantiator {
    let initialize: (() -> Any);
    init(_ i: (() -> Any)) {
        self.initialize = i
    }
}

class Injector<T> {
    let val: T;
    
    init(_ val: T) {
        self.val = val;
    }
    
    func injecting(consumer: (T) -> ()) -> T {
        consumer(self.val);
        return self.val;
    }
}


class Container {
    static let sharedInstance = Container()
    var services = [String: Instantiator]()
    
    static func putServices(services: [(key: Any, value: (() -> Any))]) {
        let instance = Container.sharedInstance
        
        services.forEach({ service in
            let keyStr = String(service.key)
            instance.services[keyStr] = Instantiator(service.value)
        })
    }
    
    func instantiate<T>(type: T.Type) -> Injector<T> {
        let typeToStr = String(type);
        let svc = services[typeToStr]?.initialize() as! T
        
        return Injector(svc);
    }
    
    func get<T>(type: T.Type) -> T {
        let typeToStr = String(type);
        let svc = services[typeToStr]?.initialize() as! T
        
        return svc
    }
    
}