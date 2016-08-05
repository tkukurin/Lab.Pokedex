//
//  AsyncImageLoader.swift
//  Homework
//
//  Created by Infinum on 8/5/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import Foundation
import UIKit

protocol UrlImageLoader {
    func loadFrom(url: String, callback: (UIImage? -> ()))
}

class AsyncImageLoader : UrlImageLoader {
    
    func loadFrom(url: String, callback: (UIImage? -> ())) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let image = AsyncImageLoader.getImage(url)
            
            dispatch_async(dispatch_get_main_queue(), {
                callback(image)
            });
        });
    }
    
    private static func getImage(urlSuffix: String) -> UIImage? {
        return NSURL(string: urlSuffix)
            .flatMap { NSData(contentsOfURL: $0) }
            .flatMap { UIImage(data: $0) }
    }
}