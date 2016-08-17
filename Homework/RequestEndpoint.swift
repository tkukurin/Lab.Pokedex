
class RequestEndpoint {
    static let REQUEST_DOMAIN = "https://pokeapi.infinum.co/"
    static let USER_ACTION_CREATE_OR_DELETE = "api/v1/users"
    static let USER_ACTION_LOGIN = "api/v1/users/login"
    static let USER_ACTION_LOGOUT = "/api/v1/users/logout"
    static let POKEMON_ACTION = "api/v1/pokemons"
    
    static func forComments(pokemonId: Int) -> String {
        return POKEMON_ACTION + "/\(pokemonId)/comments"
    }
    
    static func forUsers(userId: String) -> String {
        return USER_ACTION_CREATE_OR_DELETE + "/\(userId)"
    }
    
    static func forImages(imageUrlWithStartingForwardSlash: String) -> String {
        let advance = min(imageUrlWithStartingForwardSlash.characters.count, 1)
        return imageUrlWithStartingForwardSlash
            .substringFromIndex(imageUrlWithStartingForwardSlash.startIndex.advancedBy(advance))
    }
    
    static func resolveFullUrl(resourceWithoutStartingForwardSlash: String) -> String {
        return REQUEST_DOMAIN + resourceWithoutStartingForwardSlash
    }
}