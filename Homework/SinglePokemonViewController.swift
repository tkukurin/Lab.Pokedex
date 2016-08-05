import UIKit

class SinglePokemonViewController: UIViewController {
    static let IMAGE_BASE_URL = NSURL(string: ServerRequestor.REQUEST_DOMAIN)
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var heroImage: UIImageView!
    
    var pokemon : Pokemon!
    var imageLoader: UrlImageLoader!
    
    override func viewDidLoad() {
        imageLoader = Container.sharedInstance.getImageLoader()
        
        title = pokemon.attributes.name
        heroImage.contentMode = .ScaleAspectFit
        
        print("got pokemon \(pokemon)!")
        loadPokemonData(pokemon)
    }
    
    func loadPokemonData(pokemon: Pokemon) {
        ProgressHud.show()
        
        Result.ofNullable(pokemon.attributes.imageUrl)
            .ifSuccessfulDo({ self.loadImage($0) })
        // .ifFailedDo({ load image  })
    }
    
    func loadImage(urlEndpoint: String) {
        let fullPath = ServerRequestor.REQUEST_DOMAIN + urlEndpoint
        imageLoader.loadFrom(fullPath, callback: heroImageReceivedCallback)
    }
    
    func heroImageReceivedCallback(image: UIImage?) {
        Result.ofNullable(image)
            .ifSuccessfulDo({ self.heroImage.image = $0 })
        ProgressHud.dismiss()
    }
    
    /*func loadImageAsync(imageUrl: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let image = self.imageFromUrlSuffix(imageUrl)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.heroImage.image = image
                ProgressHud.dismiss()
            });
        });
    }
    
    func imageFromUrlSuffix(urlSuffix: String) -> UIImage? {
        return NSURL(string: urlSuffix, relativeToURL: SinglePokemonViewController.IMAGE_BASE_URL)
            .flatMap { NSData(contentsOfURL: $0) }
            .flatMap { UIImage(data: $0) }
    }*/
    
}