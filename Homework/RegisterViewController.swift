

import UIKit
import Unbox

typealias UserRegisterData = (email:String, username: String, password: String, confirmedPassword: String)

class RegisterViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localStorageAdapter = Container.sharedInstance.get(LocalStorageAdapter.self)
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
        
        emailTextField.text = "nottestmail@email.com"
        usernameTextField.text = "nottestuser"
        passwordTextField.text = "longpassword"
        confirmPasswordTextField.text = "longpassword"
    }
}

extension  RegisterViewController {
    
    @IBAction func didTapSignUpButton(sender: AnyObject) {
        requireFilledTextFields()
            .ifPresent(sendRegisterRequest)
            .orElseDo({ _ in ProgressHud.indicateFailure() })
    }
    
    private func requireFilledTextFields() -> Result<UserRegisterData> {
        guard let email = emailTextField.text where !email.isEmpty,
            let username = usernameTextField.text where !username.isEmpty,
            let password = passwordTextField.text where !password.isEmpty,
            let confirmedPassword = confirmPasswordTextField?.text where !confirmedPassword.isEmpty else {
                return Result.error("Please fill out all the fields.")
        }
        
        return Result.of((email, username, password, confirmedPassword))
    }
    
    private func sendRegisterRequest(userData: UserRegisterData) {
        ProgressHud.show()
        
        ApiRegisterRequest()
            .setSuccessHandler(persistUserAndGoToHomescreen)
            .setFailureHandler({ ProgressHud.indicateFailure("Could not send data to server") })
            .doRegister(userData)
    }
    
    private func persistUserAndGoToHomescreen(user: User) {
        ProgressHud.indicateSuccess("Logged in as \(user.attributes.username)")
        
        localStorageAdapter
            .persistUser(emailTextField.text!, passwordTextField.text!)
        
        let pokemonListViewController = storyboard?
            .instantiateViewControllerWithIdentifier("pokemonListViewController") as! PokemonListViewController
        pokemonListViewController.user = user
        
        navigationController?.pushViewController(pokemonListViewController, animated: true)
    }
    
}

