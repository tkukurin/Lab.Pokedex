import Unbox

struct Comment: Unboxable {
    
    let id: Int?
    let type: String?
    let attributes: CommentAttributes?
    let userId: String?
    
    init(unboxer: Unboxer) {
        self.id = unboxer.unbox("id")
        self.attributes = unboxer.unbox("attributes")
        self.type = unboxer.unbox("type")
        self.userId = unboxer.unbox("relationships.author.data.id")
    }
    
}

struct CommentAttributes: Unboxable {
    private static let DATE_FORMATTER = NSDateFormatter()
    
    let content: String?
    let createdAt: String?
    
    init(unboxer: Unboxer) {
        CommentAttributes.DATE_FORMATTER.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.content = unboxer.unbox("content")
        self.createdAt = unboxer.unbox("created-at")
        
//        self.createdAt = unboxer.unbox(RequestKeys.PokeAttributes.CREATED_AT,
//                                       formatter: CommentAttributes.DATE_FORMATTER)
    }
    
}

struct CommentCreatedResponse: Unboxable {
    var comment: Comment
    
    init(unboxer: Unboxer) {
        comment = unboxer.unbox("data")
    }
}