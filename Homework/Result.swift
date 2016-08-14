//
// Wrapper class for method returns.
// Allows for perhaps more elegant, functional-style error handling.
// Static methods should be used to construct objects of type Result<T>.
//

class Result<T> {
    var value: T?
    var error: Exception?
    
    private init() {}
    
    private init(value: T) {
        self.value = value
    }
    
    private init(error: String) {
        self.error = Exception(cause: error)
    }
    
    func map<R>(f: (T throws -> R)) -> Result<R> {
        let retVal = Result<R>()
        
        if let _: Exception = self.error {
            retVal.error = self.error
        } else if let value:T = self.value {
            do {
                retVal.value = try f(value)
            } catch {
                retVal.error = Exception(cause: "\(error)")
            }
        }
        
        return retVal
    }
    
    func ifSuccessfulDo(f: ((T) -> ())) -> Result<T> {
        if let value: T = self.value {
            f(value)
        }
        return self
    }
    
    func ifFailedDo(consumer: (Exception) -> ()) {
        if let error: Exception = self.error {
            consumer(error)
        }
    }
    
    func ifFailedDo(runnable: () -> ()) {
        if let _: Exception = self.error {
            runnable()
        }
    }
    
    func ifFailedReturn(supplier: () -> T) -> T {
        guard let value:T = self.value else { return supplier() }
        return value
    }
    
}

extension Result {
    static func of(opt: T) -> Result<T> {
        return Result<T>(value: opt)
    }
    
    static func ofNullable(opt: T?) -> Result<T> {
        guard let opt: T = opt else {
            return Result.error()
        }
        return Result.of(opt)
    }
    
    static func error(cause: String = "") -> Result<T> {
        return Result<T>(error: cause)
    }
}