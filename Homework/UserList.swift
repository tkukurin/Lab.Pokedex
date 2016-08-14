
import Unbox

struct UserList: Unboxable {
    let users: [User]
    
    init(unboxer: Unboxer) {
        users = unboxer.unbox(ApiRequestConstants.DATA)
    }
}