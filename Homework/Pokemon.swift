
import Unbox

struct Pokemon : Unboxable {
    var id : Int
    var type : String
    var attributes : PokeAttributes
    
    init(unboxer: Unboxer) {
        id = unboxer.unbox(ApiRequestConstants.ID)
        type = unboxer.unbox(ApiRequestConstants.TYPE)
        attributes = unboxer.unbox(ApiRequestConstants.ATTRIBUTES)
    }
}

struct PokeAttributes : Unboxable {
    
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
    var gender: String?
    
    init(unboxer : Unboxer) {
        name = unboxer.unbox(ApiRequestConstants.PokeAttributes.NAME)
        baseExperience = unboxer.unbox(ApiRequestConstants.PokeAttributes.BASE_EXPERIENCE)
        isDefault = unboxer.unbox(ApiRequestConstants.PokeAttributes.IS_DEFAULT)
        order = unboxer.unbox(ApiRequestConstants.PokeAttributes.ORDER)
        height = unboxer.unbox(ApiRequestConstants.PokeAttributes.HEIGHT)
        weight = unboxer.unbox(ApiRequestConstants.PokeAttributes.WEIGHT)
        createdAt = unboxer.unbox(ApiRequestConstants.CREATED_AT,
                                  formatter: ApiRequestConstants.DATE_FORMATTER)
        updatedAt = unboxer.unbox(ApiRequestConstants.UPDATED_AT,
                                  formatter: ApiRequestConstants.DATE_FORMATTER)
        imageUrl = unboxer.unbox(ApiRequestConstants.PokeAttributes.IMAGE_URL)
        description = unboxer.unbox(ApiRequestConstants.PokeAttributes.DESCRIPTION)
        totalVoteCount = unboxer.unbox(ApiRequestConstants.PokeAttributes.TOTAL_VOTE_COUNT)
        gender = unboxer.unbox(ApiRequestConstants.PokeAttributes.GENDER)
    }
}

struct PokemonCreatedResponse: Unboxable {
    
    let pokemon: Pokemon
    
    init(unboxer: Unboxer) {
        pokemon = unboxer.unbox(ApiRequestConstants.DATA)
    }
    
}
