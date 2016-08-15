

import UIKit

class Cache<KeyType: Hashable, ValueType> {
    
    var cache: [KeyType: ValueType]
    var keys: [KeyType?]
    
    let maxCacheSize: Int
    var keyInsertionIndex: Int
    
    init(maxCacheSize: Int) {
        self.cache = [KeyType: ValueType]()
        self.keyInsertionIndex = 0
        self.maxCacheSize = maxCacheSize
        self.keys = [KeyType?](count: maxCacheSize, repeatedValue: nil)
    }
    
    func store(key: KeyType, value: ValueType) {
        keys[keyInsertionIndex] = key
        updateInsertionIndexAndClearCacheIfNecessary()
        
        cache[key] = value
    }
    
    func updateInsertionIndexAndClearCacheIfNecessary() {
        keyInsertionIndex = (keyInsertionIndex + 1) % maxCacheSize
        
        Result
            .ofNullable(keys[keyInsertionIndex])
            .ifPresent({ self.cache.removeValueForKey($0) })
    }
    
    func get(key: KeyType) -> Result<ValueType> {
        return Result.ofNullable(cache[key])
    }
    
}
