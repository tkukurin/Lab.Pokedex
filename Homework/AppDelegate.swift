//
//  AppDelegate.swift
//  Homework
//
//  Created by Infinum on 8/5/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit
import Unbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!
    var mainStoryboard: UIStoryboard!
    var navigationController: UINavigationController!
    var serverRequestor: ServerRequestor!

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = (mainStoryboard.instantiateInitialViewController() as! UINavigationController)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = navigationController
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        getLocalUserData()
            .ifSuccessfulDo(showPokemonListScreen)
            .ifFailedDo(showLoginScreen)
        
        return true
    }
    
    private func getLocalUserData() -> Result<UserLoginData> {
        return Container.sharedInstance.getLocalStorageAdapter().loadUser()
    }
    
    private func showPokemonListScreen(userLoginData: UserLoginData) {
        let loginRequestMap = JsonMapBuilder.buildLoginRequest(userLoginData)
        serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: loginRequestMap,
                               callback: userLoginCallback)
    }
    
    func userLoginCallback(response: ServerResponse<AnyObject>) {
        response
            .ifSuccessfulDo(loadUserAndShowPokemonListScreen)
            .ifFailedDo(showLoginScreen)
    }
    
    private func loadUserAndShowPokemonListScreen(data: NSData) throws {
        let user : User = try Unbox(data)
        let loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        
        let pokemonListViewController = mainStoryboard.instantiateViewControllerWithIdentifier("pokemonListViewController") as! PokemonListViewController
        pokemonListViewController.user = user
        
        navigationController.pushViewController(loginViewController, animated: false)
        loginViewController.navigationController?.pushViewController(pokemonListViewController, animated: false)
    }
    
    private func showLoginScreen(ignorable: Exception) {
        let loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        navigationController.pushViewController(loginViewController, animated: true)
    }

}

