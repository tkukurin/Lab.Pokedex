import UIKit
import Unbox

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var alertUtils: AlertUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        
        getExistingRegistration()
            .ifSuccessfulDo({ self.sendLoginRequest($0) })
        
        usernameTextField.text = "tkukurin@gmail.com"
        passwordTextField.text = "longpassword"
    }
    
    private func getExistingRegistration() -> Result<UserLoginData> {
        return Container
                .sharedInstance
                .getLocalStorageAdapter()
                .loadUser()
    }
}

extension LoginViewController {
    
    @IBAction func loginButtonTap(sender: UIButton) {
        requireFilledTextFields()
            .map({ self.sendLoginRequest($0) })
            .ifFailedDo({ self.alertUtils.alert("\($0)") })
    }
    
    private func requireFilledTextFields() -> Result<UserLoginData> {
        guard let username = usernameTextField.text where !username.isEmpty,
              let password = passwordTextField.text where !password.isEmpty else {
                return Result.error("Please enter username and password.")
        }
        
        return Result.of((username, password))
    }
    
    private func sendLoginRequest(userData: UserLoginData) {
        let loginRequest = buildLoginRequest(userData)
        
        ProgressHud.show()
        ServerRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: loginRequest,
                               callback: serverActionCallback)
    }
    
    private func buildLoginRequest(userData: UserLoginData) -> JsonType {
        return  JsonMapBuilder.use({ builder in
            builder.addParam(RequestKeys.UserAttributes.USERNAME, userData.username)
                .addParam(RequestKeys.UserAttributes.PASSWORD, userData.password)
                .wrapWithKey(RequestKeys.User.ATTRIBUTES)
                .wrapWithKey(RequestKeys.User.DATA_PREFIX)
        })
    }
    
    func serverActionCallback(response: ServerResponse<AnyObject>) {
        response
            .ifSuccessfulDo(loadUserAndLogin)
            .ifFailedDo({ ProgressHud.indicateFailure("\($0)") })
    }
    
    private func loadUserAndLogin(data: NSData) throws {
        let user : User = try Unbox(data)
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