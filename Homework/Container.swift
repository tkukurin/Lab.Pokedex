
import Foundation
import UIKit

class Instantiator {
    let initialize: (() -> Any);
    init(_ i: (() -> Any)) {
        self.initialize = i
    }
}

class Container {
    typealias ServiceClassToInstantatingClosure = (key: Any, value: (() -> Any))
    
    static let sharedInstance = Container()
    var services = [String: Instantiator]()
    
    static func putServices(services: [ServiceClassToInstantatingClosure]) {
        let instance = Container.sharedInstance
        
        services.forEach({ service in
            let keyStr = String(service.key)
            instance.services[keyStr] = Instantiator(service.value)
        })
    }
    
    func get<T>(type: T.Type) -> T {
        let typeToStr = String(type);
        let svc = services[typeToStr]?.initialize() as! T
        
        return svc
    }
    
}