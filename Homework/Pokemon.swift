import Unbox

struct Pokemon : Unboxable {
    var id : Int
    var type : String
    var attributes : PokeAttributes
    
    init(unboxer: Unboxer) {
        id = unboxer.unbox(RequestKeys.Pokemon.ID)
        type = unboxer.unbox(RequestKeys.Pokemon.TYPE)
        attributes = unboxer.unbox(RequestKeys.Pokemon.ATTRIBUTES)
    }
}

struct PokeAttributes : Unboxable {
    private static let DATE_FORMATTER = NSDateFormatter()
    
    var name : String?
    var baseExperience: Int?
    var isDefault: Bool?
    var order: Int?
    var height : Double?
    var weight : Double?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    var imageUrl : String?
    var description: String?
    var totalVoteCount: Int?
    
    init(unboxer : Unboxer) {
        PokeAttributes.DATE_FORMATTER.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        
        name = unboxer.unbox(RequestKeys.PokeAttributes.NAME)
        baseExperience = unboxer.unbox(RequestKeys.PokeAttributes.BASE_EXPERIENCE)
        isDefault = unboxer.unbox(RequestKeys.PokeAttributes.IS_DEFAULT)
        order = unboxer.unbox(RequestKeys.PokeAttributes.ORDER)
        height = unboxer.unbox(RequestKeys.PokeAttributes.HEIGHT)
        weight = unboxer.unbox(RequestKeys.PokeAttributes.WEIGHT)
        createdAt = unboxer.unbox(RequestKeys.PokeAttributes.CREATED_AT,
                                  formatter: PokeAttributes.DATE_FORMATTER)
        updatedAt = unboxer.unbox(RequestKeys.PokeAttributes.UPDATED_AT,
                                  formatter: PokeAttributes.DATE_FORMATTER)
        imageUrl = unboxer.unbox(RequestKeys.PokeAttributes.IMAGE_URL)
        description = unboxer.unbox(RequestKeys.PokeAttributes.DESCRIPTION)
        totalVoteCount = unboxer.unbox(RequestKeys.PokeAttributes.TOTAL_VOTE_COUNT)
    }
}