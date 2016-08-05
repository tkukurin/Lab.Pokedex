//
//	JsonMapBuilder.swift
//
//	Convenience class; used for simple JSON param chaining.
//

class JsonMapBuilder {
    
    private var items: JsonType
    
    static func use( consumer: (JsonMapBuilder) -> JsonMapBuilder ) -> [String: AnyObject] {
        let jmb = JsonMapBuilder()
        return consumer(jmb).build()
    }
    
    private func build() -> JsonType {
        return items
    }
    
    private init() {
        items = [String: AnyObject]()
    }
    
    func addParam(key: String, _ value: String) -> JsonMapBuilder {
        items[key] = value
        return self
    }
    
    func nestParam(key: String, _ value: JsonMapBuilder) -> JsonMapBuilder {
        items[key] = value.build()
        return self
    }
    
    func wrapWithKey(key: String) -> JsonMapBuilder {
        let wrap = [ key: self.items ]
        self.items = wrap
        return self
    }
    
}