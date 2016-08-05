import Unbox

struct PokemonList : Unboxable {
    var pokemons : [Pokemon]
    var links: PokeListPagination
    
    init(unboxer: Unboxer) {
        pokemons = unboxer.unbox("data")
        links = unboxer.unbox("links")
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
        current = unboxer.unbox("self")
        next = unboxer.unbox("next")
        last = unboxer.unbox("last")
    }
}