import UIKit
import Unbox

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        localStorageAdapter = Container.sharedInstance.getLocalStorageAdapter()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
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
        guard let username = emailTextField.text where !username.isEmpty else {
            AnimationUtils.shakeFieldAnimation(emailTextField)
            return Result.error()
        }
        
        guard let password = passwordTextField.text where !password.isEmpty else {
            AnimationUtils.shakeFieldAnimation(passwordTextField)
            return Result.error()
        }
        
        return Result.of((username, password))
    }
    
    private func sendLoginRequest(userData: UserLoginData) {
        ProgressHud.show()
        
        ApiLoginRequest()
            .setSuccessHandler(persistUserAndGoToHomescreen)
            .setFailureHandler({ ProgressHud.indicateFailure("Error logging in") })
            .doLogin(userData)
    }
    
    private func persistUserAndGoToHomescreen(user: User) {
        ProgressHud.indicateSuccess()
        
        localStorageAdapter
            .persistUser(emailTextField.text!, passwordTextField.text!)
        
        let pokemonListViewController = storyboard?
            .instantiateViewControllerWithIdentifier("pokemonListViewController") as! PokemonListViewController
        pokemonListViewController.user = user
        
        navigationController?.pushViewController(pokemonListViewController, animated: true)
    }
    
    @IBAction func didTapRegisterButton(sender: AnyObject) {
        let registerViewController = storyboard?
            .instantiateViewControllerWithIdentifier("registerViewController") as! RegisterViewController
        
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
}