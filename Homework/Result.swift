//
// Wrapper class for method returns.
// Allows for perhaps more elegant, functional-style error handling.
// Static methods should be used to construct objects of type Result<T>.
//
// One potential pitfall with using this class is that ifFailed and ifSuccessful
// can potentially be abused in a notation such as:
// result.ifFailedDo(...).ifSuccessfulDo(...).ifFailedDo(...) (...)
//
// A possible solution to the problem above would be restricting only one
// (for instance, ifSuccessful) method to return Result<R>, and then
// renaming the ifFailed method to orElse and returning void:
// result.ifSuccessfulDo(...)
//       .ifSuccessfulDo(...)
//       .orElse(...) // returns void, no further chaining allowed.
//

class Result<T> {
    private var value: T?
    private var error: Exception?
    
    private init() {}
    
    private init(value: T) {
        self.value = value
    }
    
    private init(error: String) {
        self.error = Exception(cause: error)
    }
    
    func map<R>(f: ((T) throws -> (R))) -> Result<R> {
        let retVal = Result<R>()
        if let _: Exception = self.error {
            retVal.error = self.error
        } else {
            do {
                retVal.value = try f(self.value!)
            } catch {
                retVal.error = Exception(cause: "\(error)")
            }
        }
        return retVal
    }
    
    func ifFailedDo(consumer: (Exception) -> ()) -> Result<T> {
        if let error: Exception = self.error {
            consumer(error)
        }
        return self
    }
    
    func ifFailedReturn(supplier: () -> T) -> Result<T> {
        if let _: Exception = self.error {
            return Result<T>(value: supplier())
        }
        
        return self
    }
    
    func ifSuccessfulDo(f: ((T) -> ())) -> Result<T> {
        if let value: T = self.value {
            f(value)
        }
        return self
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