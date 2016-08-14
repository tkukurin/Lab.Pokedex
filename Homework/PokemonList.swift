
import Unbox

struct PokemonList: Unboxable {
    var pokemons: [Pokemon]
    var links: PokeListPagination?
    
    init(unboxer: Unboxer) {
        pokemons = unboxer.unbox(ApiRequestConstants.DATA)
        links = unboxer.unbox(ApiRequestConstants.Pokemon.LINKS)
    }
    
    func get(atIndex: Int) -> Pokemon {
        return pokemons[atIndex]
    }
}

struct PokeListPagination: Unboxable {
    let current: NSURL
    let next: NSURL?
    let last: NSURL?
    
    init(unboxer: Unboxer) {
        current = unboxer.unbox(ApiRequestConstants.PokeListLinks.CURRENT)
        next = unboxer.unbox(ApiRequestConstants.PokeListLinks.NEXT)
        last = unboxer.unbox(ApiRequestConstants.PokeListLinks.PREV)
    }
}