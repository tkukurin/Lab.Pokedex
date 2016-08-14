
import Unbox

struct User : Unboxable {
    let id: Int
    let type: String?
    let attributes: UserAttributes
    
    init(unboxer : Unboxer) {
        id = unboxer.unbox(ApiRequestConstants.DATA + "." + ApiRequestConstants.ID)
        type = unboxer.unbox(ApiRequestConstants.DATA + "." + ApiRequestConstants.TYPE)
        attributes = unboxer.unbox(ApiRequestConstants.DATA + "." + ApiRequestConstants.ATTRIBUTES)
    }
    
}

struct UserAttributes : Unboxable {
    let authToken : String?
    let email : String
    let username : String
    
    init(unboxer : Unboxer) {
        authToken = unboxer.unbox(ApiRequestConstants.UserAttributes.AUTH_TOKEN)
        email = unboxer.unbox(ApiRequestConstants.UserAttributes.EMAIL)
        username = unboxer.unbox(ApiRequestConstants.UserAttributes.USERNAME)
    }
}