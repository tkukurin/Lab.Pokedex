

import UIKit
import Unbox

typealias UserRegisterData = (email:String, username: String, password: String, confirmedPassword: String)

class RegisterViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var localStorageAdapter: LocalStorageAdapter!
    private var registerRequest: ApiUserRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localStorageAdapter = Container.sharedInstance.get(LocalStorageAdapter.self)
        registerRequest = Container.sharedInstance.get(ApiUserRequest.self)
        
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
            .orElseDo({ ProgressHud.indicateFailure("Please fill out all the fields.") })
    }
    
    private func requireFilledTextFields() -> Result<UserRegisterData> {
        var values = [String]()
        let fields = [ emailTextField,
            usernameTextField,
            passwordTextField,
            confirmPasswordTextField ]
        
        fields.forEach({ field in
                if let content = field.text where !content.isEmpty {
                    values.append(content)
                } else {
                    AnimationUtils.shakeFieldAnimation(field)
                }
        })
        
        if values.count != fields.count {
            return Result.error()
        } else {
            return Result.of((email: values[0],
                username: values[1],
                password: values[2],
                confirmedPassword: values[3]))
        }
    }
    
    private func sendRegisterRequest(userData: UserRegisterData) {
        ProgressHud.show()
        
        registerRequest
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

