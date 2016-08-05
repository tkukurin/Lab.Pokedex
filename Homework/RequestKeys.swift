struct RequestKeys {
    struct User {
        private init() {}
        
        static let DATA_PREFIX = "data"
        static let ID = "id"
        static let ATTRIBUTES = "attributes"
        static let TYPE = "type"
    }
    
    struct UserAttributes {
        private init() {}
        
        static let AUTH_TOKEN = "auth-token"
        static let USERNAME = "username"
        static let PASSWORD = "password"
        static let CONFIRMED_PASSWORD = "confirmedPassword"
        static let EMAIL = "email"
    }
    
    struct Pokemon {
        private init() {}
        
        static let ID = "id"
        static let TYPE = "type"
        static let ATTRIBUTES = "attributes"
    }
    
    struct PokeAttributes {
        private init() {}
        
        static let NAME = "name"
        static let BASE_EXPERIENCE = "base-experience"
        static let IS_DEFAULT = "is-default"
        static let ORDER = "order"
        static let HEIGHT = "height"
        static let WEIGHT = "weight"
        static let CREATED_AT = "created-at"
        static let UPDATED_AT = "updated-at"
        static let IMAGE_URL = "image-url"
        static let DESCRIPTION = "description"
        static let TOTAL_VOTE_COUNT = "total-vote-count"
    }
}