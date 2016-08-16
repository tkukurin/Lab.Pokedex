//
// shared instance is to be used for app-wide image caching
// and improved user experience.
//
// ideal situation would be to limit the cache in size (MB) rather than
// number of items, but since I don't have the time this should do:
// worst case cca max. image size of 4MB * 30 images = 120MB
//

import UIKit

class ImageCache: Cache<String, UIImage> {
    static let sharedInstance = ImageCache()
    
    private init() {
        super.init(maxCacheSize: 30)
    }
}