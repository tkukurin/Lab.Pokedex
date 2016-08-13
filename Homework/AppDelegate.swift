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

    var window: UIWindow?
    var mainStoryboard: UIStoryboard?
    var navigationController: UINavigationController?
    
    private var serverRequestor: ServerRequestor!

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        navigationController = (mainStoryboard?.instantiateViewControllerWithIdentifier("mainNavigationController")
            as! UINavigationController)
        window?.rootViewController = navigationController
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        getExistingRegistration()
            .ifSuccessfulDo(showPokemonListScreen)
            .ifFailedDo(showLoginScreen)
        
        return true
    }
    
    private func showPokemonListScreen(userLoginData: UserLoginData) {
        let loginRequestMap = JsonMapBuilder.buildLoginRequest(userLoginData)
        serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: loginRequestMap,
                               callback: serverActionCallback)
    }
    
    func serverActionCallback(response: ServerResponse<AnyObject>) {
        response
            .ifSuccessfulDo(loadUserAndShowPokemonListScreen)
            .ifFailedDo(showLoginScreen)
    }
    
    private func loadUserAndShowPokemonListScreen(data: NSData) throws {
        let user : User = try Unbox(data)
        let pokemonListViewController = mainStoryboard?.instantiateViewControllerWithIdentifier("pokemonListViewController") as! PokemonListViewController
        pokemonListViewController.user = user
        navigationController?.pushViewController(pokemonListViewController, animated: true)
    }
    
    private func showLoginScreen(ignorable: Exception) {
        let loginViewController = mainStoryboard?.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    private func getExistingRegistration() -> Result<UserLoginData> {
        return Container.sharedInstance.getLocalStorageAdapter().loadUser()
    }

}

