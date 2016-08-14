
import Unbox

struct Comment: Unboxable {
    
    let id: Int?
    let type: String?
    let attributes: CommentAttributes?
    let userId: String?
    
    init(unboxer: Unboxer) {
        self.id = unboxer.unbox(ApiRequestConstants.ID)
        self.attributes = unboxer.unbox(ApiRequestConstants.ATTRIBUTES)
        self.type = unboxer.unbox(ApiRequestConstants.TYPE)
        self.userId = unboxer.unbox(ApiRequestConstants.Comment.USER_ID_PATH)
    }
    
}

struct CommentAttributes: Unboxable {
    
    let content: String?
    let createdAt: NSDate?
    
    init(unboxer: Unboxer) {
        self.content = unboxer.unbox(ApiRequestConstants.Comment.CONTENT)
        
        let createdAtStr: String = unboxer.unbox(ApiRequestConstants.CREATED_AT)
        self.createdAt = ApiRequestConstants.DATE_FORMATTER.dateFromString(createdAtStr)
    }
    
}

struct CommentCreatedResponse: Unboxable {
    var comment: Comment
    
    init(unboxer: Unboxer) {
        comment = unboxer.unbox(ApiRequestConstants.DATA)
    }
}