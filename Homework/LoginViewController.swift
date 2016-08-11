import UIKit
import Unbox

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var alertUtils: AlertUtils!
    private var localStorageAdapter: LocalStorageAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = nil
        
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        localStorageAdapter = Container.sharedInstance.getLocalStorageAdapter()
        
        emailTextField.text = "tkukurin@gmail.com"
        passwordTextField.text = "longpassword"
    }
    
}

extension LoginViewController {
    
    @IBAction func loginButtonTap(sender: UIButton) {
        requireFilledTextFields()
            .map(sendLoginRequest)
            .ifFailedDo({ self.alertUtils.alert("\($0.cause)") })
    }
    
    private func requireFilledTextFields() -> Result<UserLoginData> {
        guard let username = emailTextField.text where !username.isEmpty,
              let password = passwordTextField.text where !password.isEmpty else {
                return Result.error("Please enter username and password.")
        }
        
        return Result.of((username, password))
    }
    
    private func sendLoginRequest(userData: UserLoginData) {
        let loginRequest = JsonMapBuilder.buildLoginRequest(userData)
        print("Using request \(loginRequest)")
        
        ProgressHud.show()
        ServerRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: loginRequest,
                               callback: serverActionCallback)
    }
    
    func serverActionCallback(response: ServerResponse<AnyObject>) {
        response
            .ifSuccessfulDo(loadUserAndLogin)
            .ifFailedDo({ ProgressHud.indicateFailure("\($0.cause)") })
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