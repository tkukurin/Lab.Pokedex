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
        setupSharedContainer()
        setupInitialWindows()
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
        
        getLocalUserData()
            .ifPresent(showPokemonListScreen)
            .orElseDo(showLoginScreen)
        
        return true
    }
    
    func setupSharedContainer() {
        let storageAdapter = LocalStorageAdapter()
        let serverRequestor = ServerRequestor()
        let imageLoader = AsyncImageLoader()
        Container.putServices([
            (key: LocalStorageAdapter.self, value: { storageAdapter }),
            (key: ServerRequestor.self, value: { serverRequestor }),
            (key: UrlImageLoader.self, value: { imageLoader })
        ])
        
        let loginHandler = ApiLoginRequest()
        let registerHandler = ApiRegisterRequest()
        let commentsHandler = ApiCommentRequest()
        Container.putServices([
            (key: ApiLoginRequest.self, value: { loginHandler }),
            (key: ApiRegisterRequest.self, value: { registerHandler }),
            (key: ApiCommentRequest.self, value: { commentsHandler}),
        ])
    }
    
    func setupInitialWindows() {
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = (mainStoryboard.instantiateInitialViewController() as! UINavigationController)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = navigationController
    }
    
    private func getLocalUserData() -> Result<UserLoginData> {
        return Container.sharedInstance.get(LocalStorageAdapter.self).loadUser()
    }
    
    private func showPokemonListScreen(userLoginData: UserLoginData) {
        let loginRequestMap = JsonMapBuilder.buildLoginRequest(userLoginData)
        serverRequestor.doPost(RequestEndpoint.USER_ACTION_LOGIN,
                               jsonReq: loginRequestMap,
                               callback: userLoginCallback)
    }
    
    func userLoginCallback(response: ServerResponse<AnyObject>) {
        response
            .ifPresent(loadUserAndShowPokemonListScreen)
            .orElseDo(showLoginScreen)
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

