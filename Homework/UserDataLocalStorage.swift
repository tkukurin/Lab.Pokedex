
protocol UserDataLocalStorage {
    func persistUser(email: String, _ password: String)
    func loadUser() -> Result<UserLoginData>
    func deleteActiveUser()
}