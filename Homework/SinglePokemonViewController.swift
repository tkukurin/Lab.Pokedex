import UIKit

class SinglePokemonViewController: UIViewController {
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonDescriptionTextField: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var abilitiesLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var pokemon : Pokemon!
    var imageLoader: UrlImageLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLoader = Container.sharedInstance.getImageLoader()
        title = pokemon.attributes.name
        loadPokemonData(pokemon)
    }
    
    func loadPokemonData(pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.attributes.name
        pokemonDescriptionTextField.text = pokemon.attributes.description
        heightLabel.text = getOrDefault(pokemon.attributes.height)
        weightLabel.text = getOrDefault(pokemon.attributes.weight)
        abilitiesLabel.text = getOrDefault(pokemon.attributes.createdAt)
        typeLabel.text = getOrDefault(pokemon.type)
        
        Result
            .ofNullable(pokemon.attributes.imageUrl)
            .ifSuccessfulDo(loadImage)
    }
    
    func getOrDefault<T>(value: T?, defaultValue:String = "?") -> String {
        if let value: T = value { return String(value) }
        return defaultValue
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