

import UIKit
import Unbox

typealias UserRegisterData = (email:String,
                              username: String,
                              password: String,
                              confirmedPassword: String)

class RegisterViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var userDataLocalStorage: UserDataLocalStorage!
    private var registerRequest: ApiUserRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDataLocalStorage = Container.sharedInstance.get(UserDataLocalStorage.self)
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
        var didCollectAllRequiredValues = true
        
        getRequiredFields().forEach({ field in
            if let content = field.text where !content.isEmpty {
                values.append(content)
            } else {
                didCollectAllRequiredValues = false
                AnimationUtils.shakeFieldAnimation(field)
            }
        })
        
        return didCollectAllRequiredValues
            ? Result.of(arrayToRegisterData(values))
            : Result.error()
    }
    
    private func getRequiredFields() -> [UITextField] {
        return [ emailTextField,
                 usernameTextField,
                 passwordTextField,
                 confirmPasswordTextField ]
    }
    
    private func arrayToRegisterData(values: [String]) -> UserRegisterData {
        return (email: values[0],
                username: values[1],
                password: values[2],
                confirmedPassword: values[3])
    }
    
    private func sendRegisterRequest(userData: UserRegisterData) {
        ProgressHud.show()
        
        registerRequest
            .setSuccessHandler(persistUserAndGoToHomescreen)
            .setFailureHandler({ ProgressHud.indicateFailure("Could not send data to server") })
            .doRegister(userData)
    }
    
    private func persistUserAndGoToHomescreen(user: User) {
        ProgressHud.indicateSuccess("Successfully logged in!")
        
        userDataLocalStorage.persistUser(emailTextField.text!, passwordTextField.text!)
        pushController(PokemonListViewController.self, injecting: { $0.loggedInUser = user })
    }
    
}

