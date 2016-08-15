

import UIKit
import Unbox

typealias UserRegisterData = (email:String, username: String, password: String, confirmedPassword: String)

class RegisterViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var alertUtils: AlertUtils!
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        localStorageAdapter = Container.sharedInstance.getLocalStorageAdapter()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        title = "Sign up"
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
            .orElseDo({ self.alertUtils.alert($0.cause) })
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
        serverRequestor.doPost(RequestEndpoint.USER_ACTION_CREATE_OR_DELETE,
                               jsonReq: JsonMapBuilder.buildRegisterRequest(userData),
                               callback: serverActionCallback)
    }
    
    func serverActionCallback(response: ServerResponse<AnyObject>) {
        response
            .ifPresent(loadUserAndLogin)
            .orElseDo({ ProgressHud.indicateFailure("\($0.cause)") })
    }
    
    private func loadUserAndLogin(data: NSData) throws {
        let user : User = try Unbox(data)
        localStorageAdapter
            .persistUser(emailTextField.text!, passwordTextField.text!)
        
        goToHomescreen(user)
        ProgressHud.indicateSuccess("Login: \(user.attributes.username)")
    }
    
    private func goToHomescreen(user: User) {
        let pokemonListViewController = storyboard?
            .instantiateViewControllerWithIdentifier("pokemonListViewController") as! PokemonListViewController
        pokemonListViewController.user = user
        
        navigationController?.pushViewController(pokemonListViewController, animated: true)
        print("User \(user)")
    }
    
}

