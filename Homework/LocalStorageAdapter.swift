import Foundation

class LocalStorageAdapter {
    private static let USERNAME_KEY = "username"
    private static let PASSWORD_KEY = "password"
    
    func persistUser(username: String, password: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setValue(username, forKey: LocalStorageAdapter.USERNAME_KEY)
        userDefaults.setValue(password, forKey: LocalStorageAdapter.PASSWORD_KEY)
    }
    
    func loadUser() -> Result<UserLoginData> {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        guard let username = userDefaults.stringForKey(LocalStorageAdapter.USERNAME_KEY),
              let password = userDefaults.stringForKey(LocalStorageAdapter.PASSWORD_KEY) else {
              return Result.error("No username and password.")  
        }
        
        return Result.of((username, password))
    }
    
    func deleteActiveUser() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(LocalStorageAdapter.USERNAME_KEY)
        userDefaults.removeObjectForKey(LocalStorageAdapter.PASSWORD_KEY)
    }
}