import UIKit

class SinglePokemonViewController: UITableViewController { //UIViewController {
    
    @IBOutlet weak var heroImage: UIImageView!
    
    var pokemon : Pokemon!
    var imageLoader: UrlImageLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLoader = Container.sharedInstance.getImageLoader()
        title = pokemon.attributes.name
        loadPokemonData(pokemon)
    }
    
    func loadPokemonData(pokemon: Pokemon) {
        Result
            .ofNullable(pokemon.attributes.imageUrl)
            .ifSuccessfulDo(loadImage)
    }
    
    func loadImage(urlEndpoint: String) {
        ProgressHud.show()
        
        let fullPath = ServerRequestor.REQUEST_DOMAIN + urlEndpoint
        imageLoader.loadFrom(fullPath, callback: heroImageReceivedCallback)
    }
    
    func heroImageReceivedCallback(image: UIImage?) {
        Result
            .ofNullable(image)
            .ifSuccessfulDo({
                self.heroImage.contentMode = .ScaleAspectFit
                self.heroImage.image = $0
            })
        ProgressHud.dismiss()
    }
    
}