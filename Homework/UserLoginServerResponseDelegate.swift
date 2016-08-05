// Login delegate
// called once the server responds with user credentials.

import UIKit
import Unbox

protocol UserLoginServerResponseDelegate: ServerResponseDelegate {
    var navigationController: UINavigationController? { get }
    var storyboard: UIStoryboard? { get }
}

extension UserLoginServerResponseDelegate {
    
    func serverActionCallback<AnyObject>(response: ServerResponse<AnyObject>) {
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
        /*let pokemonListViewController = storyboard?
            .instantiateViewControllerWithIdentifier("Home") as! PokemonListViewController
        pokemonListViewController.user = user
        
        navigationController?.pushViewController(pokemonListViewController, animated: true)*/
        print("User \(user)")
    }
}