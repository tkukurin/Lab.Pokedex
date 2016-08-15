

import UIKit

class Cache<KeyType: Hashable, ValueType> {
    
    var cache: [KeyType: ValueType]
    
    init() {
        cache = [KeyType: ValueType]()
    }
    
    func store(key: KeyType, value: ValueType) {
        cache[key] = value
    }
    
    func get(key: KeyType) -> Result<ValueType> {
        return Result.ofNullable(cache[key])
    }
    
}
