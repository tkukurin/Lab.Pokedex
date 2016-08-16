import UIKit
import Unbox

typealias UserLoginData = (email: String,
                           password: String)

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var userDataLocalStorage: UserDataLocalStorage!
    private var loginRequest: ApiUserRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDataLocalStorage = Container.sharedInstance.get(UserDataLocalStorage.self)
        loginRequest = Container.sharedInstance.get(ApiUserRequest.self)
        
        // obviously debug-only
        emailTextField.text = "nottestmail@email.com"
        passwordTextField.text = "longpassword"
    }
    
}

extension LoginViewController {
    
    @IBAction func didTapLoginButton(sender: UIButton) {
        requireFilledTextFieldsAndGetData()
            .ifPresent(sendLoginRequest)
    }
    
    private func requireFilledTextFieldsAndGetData() -> Result<UserLoginData> {
        guard let email = emailTextField.text where !email.isEmpty else {
            AnimationUtils.shakeFieldAnimation(emailTextField)
            return Result.error()
        }
        
        guard let password = passwordTextField.text where !password.isEmpty else {
            AnimationUtils.shakeFieldAnimation(passwordTextField)
            return Result.error()
        }
        
        return Result.of((email, password))
    }
    
    private func sendLoginRequest(userData: UserLoginData) {
        ProgressHud.show()
        
        loginRequest
            .setSuccessHandler(persistUserAndGoToHomescreen)
            .setFailureHandler({ ProgressHud.indicateFailure("Error logging in") })
            .doLogin(userData)
    }
    
    private func persistUserAndGoToHomescreen(user: User) {
        ProgressHud.indicateSuccess()
        
        userDataLocalStorage.persistUser(emailTextField.text!, passwordTextField.text!)
        pushController(PokemonListViewController.self, injecting: { $0.loggedInUser = user })
    }
    
    @IBAction func didTapRegisterButton(sender: AnyObject) {
        pushController(RegisterViewController.self)
    }
    
}