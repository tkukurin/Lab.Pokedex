//
//  Container.swift
//  Homework
//
//  Created by Infinum on 8/5/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import Foundation
import UIKit

enum ConstructorClosure {
    case Init(() -> AnyObject)
}

class Container {
    static let CONTROLLERS = [String: ConstructorClosure]()
    static let sharedInstance = Container();
    
    private let localStorageAdapter: LocalStorageAdapter
    private let imageLoader: UrlImageLoader
    
    private init() {
        localStorageAdapter = LocalStorageAdapter()
        imageLoader = AsyncImageLoader()
    }
    
    func getLocalStorageAdapter() -> LocalStorageAdapter {
        return localStorageAdapter
    }
    
    func getAlertUtilities(caller: UIViewController) -> AlertUtils {
        return AlertUtils(caller)
    }
    
    func getImageLoader() -> UrlImageLoader {
        return imageLoader
    }
    
}