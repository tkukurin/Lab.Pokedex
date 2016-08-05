import Foundation
import Unbox

struct User : Unboxable {
    let id: Int?
    let type: String?
    let attributes: UserAttributes
    
    init(unboxer : Unboxer) {
        id = unboxer.unbox(RequestKeys.User.ID)
        type = unboxer.unbox(RequestKeys.User.TYPE)
        attributes = unboxer.unbox(RequestKeys.User.ATTRIBUTES)
    }
    
}

struct UserAttributes : Unboxable {
    let authToken : String
    let email : String
    let username : String
    
    init(unboxer : Unboxer) {
        authToken = unboxer.unbox(RequestKeys.UserAttributes.AUTH_TOKEN)
        email = unboxer.unbox(RequestKeys.UserAttributes.EMAIL)
        username = unboxer.unbox(RequestKeys.UserAttributes.USERNAME)
    }
}