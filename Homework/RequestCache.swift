
import UIKit
import Alamofire

class RequestCache: Cache<NSObject, Request> {
    static let CANCEL_ALL_REQUESTS_ON_CLEANUP = { (request: Request) in request.cancel() }
    static let sharedInstance = RequestCache()
    
    private init() {
        super.init(maxCacheSize: 30)
        super.priorToCleanupAction = RequestCache.CANCEL_ALL_REQUESTS_ON_CLEANUP
    }
}