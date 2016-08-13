import UIKit
import Unbox

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var alertUtils: AlertUtils!
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        localStorageAdapter = Container.sharedInstance.getLocalStorageAdapter()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        emailTextField.text = "nottestmail@email.com"
        passwordTextField.text = "longpassword"
    }
    
}

extension LoginViewController {
    
    @IBAction func didTapLoginButton(sender: UIButton) {
        requireFilledTextFields()
            .ifSuccessfulDo(sendLoginRequest)
            // .ifFailedDo({ self.alertUtils.alert("\($0.cause)") })
    }
    
    @IBAction func didTapRegisterButton(sender: AnyObject) {
        let registerViewController = storyboard?
            .instantiateViewControllerWithIdentifier("registerViewController") as! RegisterViewController
        
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    private func requireFilledTextFields() -> Result<UserLoginData> {
        guard let username = emailTextField.text where !username.isEmpty else {
            shakeFieldAnimation(emailTextField)
            return Result.error()
        }
        
        guard let password = passwordTextField.text where !password.isEmpty else {
            shakeFieldAnimation(passwordTextField)
            return Result.error()
        }
        
        return Result.of((username, password))
    }
    
    func shakeFieldAnimation(txtField: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(txtField.center.x - 8, txtField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(txtField.center.x + 8, txtField.center.y))
        txtField.layer.addAnimation(animation, forKey: "position")
    }
    
    private func sendLoginRequest(userData: UserLoginData) {
        let loginRequest = JsonMapBuilder.buildLoginRequest(userData)
        print("Using request \(loginRequest)")
        
        ProgressHud.show()
        serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
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