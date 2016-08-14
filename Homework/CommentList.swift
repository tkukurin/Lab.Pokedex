
import Unbox

struct CommentList: Unboxable {
    let comments: [Comment]
    
    init(unboxer: Unboxer) {
        self.comments = unboxer.unbox(RequestKeys.DATA)
    }
}

