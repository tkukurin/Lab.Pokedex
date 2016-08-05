import UIKit

class SinglePokemonViewController: UIViewController {
    
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
    
}

extension SinglePokemonViewController {
    
}