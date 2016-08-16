import Foundation

class LocalStorageAdapter: UserDataLocalStorage {
    private static let EMAIL_KEY = "email"
    private static let PASSWORD_KEY = "password"
    
    func persistUser(email: String, _ password: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setValue(email, forKey: LocalStorageAdapter.EMAIL_KEY)
        userDefaults.setValue(password, forKey: LocalStorageAdapter.PASSWORD_KEY)
    }
    
    func loadUser() -> Result<UserLoginData> {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        guard let email = userDefaults.stringForKey(LocalStorageAdapter.EMAIL_KEY),
              let password = userDefaults.stringForKey(LocalStorageAdapter.PASSWORD_KEY) else {
              return Result.error()  
        }
        
        return Result.of((email, password))
    }
    
    func deleteActiveUser() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(LocalStorageAdapter.EMAIL_KEY)
        userDefaults.removeObjectForKey(LocalStorageAdapter.PASSWORD_KEY)
    }
}