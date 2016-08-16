
import UIKit

class Cache<KeyType: Hashable, ValueType> {
    
    var cache: [KeyType: ValueType]
    var keys: [KeyType?]
    
    let maxCacheSize: Int
    var keyInsertionIndex: Int
    var priorToCleanupAction: (ValueType) -> ()
    
    init(maxCacheSize: Int) {
        self.cache = [KeyType: ValueType]()
        self.keyInsertionIndex = 0
        self.maxCacheSize = maxCacheSize
        self.keys = [KeyType?](count: maxCacheSize, repeatedValue: nil)
        self.priorToCleanupAction = { item in }
    }
    
    func put(key: KeyType, value: ValueType) {
        keys[keyInsertionIndex] = key
        updateInsertionIndexAndClearCacheIfNecessary()
        
        cache[key] = value
    }
    
    private func updateInsertionIndexAndClearCacheIfNecessary() {
        keyInsertionIndex = (keyInsertionIndex + 1) % maxCacheSize
        
        Result
            .ofNullable(keys[keyInsertionIndex])
            .ifPresent({
                if let item = self.cache.removeValueForKey($0) {
                    self.priorToCleanupAction(item)
                }
                
            })
    }
    
    func get(key: KeyType?) -> Result<ValueType> {
        return Result.ofNullable(key)
                     .flatMap({ Result.ofNullable(self.cache[$0]) })
    }
    
    func getAndClear(key: KeyType) -> Result<ValueType> {
        let result = Result.ofNullable(cache.removeValueForKey(key))
        result.ifPresent(priorToCleanupAction)
        
        return result
    }
    
    func forEach(keyValueConsumer: (KeyType, ValueType) -> ()) {
        cache.forEach(keyValueConsumer)
    }
    
    func emptyCache() {
        forEach({ (key, value) in self.priorToCleanupAction(value) })
        
        self.cache = [KeyType: ValueType]()
        self.keyInsertionIndex = 0
        self.keys = [KeyType?](count: maxCacheSize, repeatedValue: nil)
    }
    
}