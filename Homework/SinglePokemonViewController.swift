import UIKit
import Unbox

class SinglePokemonViewController: UIViewController {
    static let DEFAULT_IMAGE = UIImage(named: "Pokeball.png")
    static let DEFAULT_STRING_IF_DATA_UNAVAILABLE = "?"
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonDescriptionTextField: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var pokemon : Pokemon!
    var image: UIImage?
    
    var loggedInUser: User!
    private var imageLoader: ApiPhotoRequest!
    private var commentRequest: ApiCommentListRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageLoader = Container.sharedInstance.get(ApiPhotoRequest.self)
        commentRequest = Container.sharedInstance.get(ApiCommentListRequest.self)
        
        title = pokemon.attributes.name
        loadPokemonData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        ProgressHud.dismiss()
    }
    
    func loadPokemonData() {
        pokemonNameLabel.text = pokemon.attributes.name
        pokemonDescriptionTextField.text = pokemon.attributes.description
        
        heightLabel.text = getOrDefaultFromDouble(pokemon.attributes.height)
        weightLabel.text = getOrDefaultFromDouble(pokemon.attributes.weight)
        genderLabel.text = getOrDefaultFromString(pokemon.attributes.gender)
        typeLabel.text = getOrDefaultFromString(pokemon.type)
        
        Result.ofNullable(image)
            .ifPresent({ self.heroImage.image = $0 })
            .orElseDo({ self.loadImageOrDisplayDefault(self.pokemon.attributes.imageUrl) })
    }
    
    func getOrDefaultFromDouble(value: Double?) -> String {
        if let value: Double = value { return String(format:"%.2f", value) }
        return SinglePokemonViewController.DEFAULT_STRING_IF_DATA_UNAVAILABLE
    }
    
    func getOrDefaultFromString(value: String?) -> String {
        if let value: String = value { return value }
        return SinglePokemonViewController.DEFAULT_STRING_IF_DATA_UNAVAILABLE
    }
    
    func loadImageOrDisplayDefault(imageUrl: String?) {
        Result
            .ofNullable(imageUrl)
            .ifPresent(loadImage)
            .orElseDo(setDefaultImage)
    }
    
    func loadImage(urlEndpoint: String) {
        ProgressHud.show()
        imageLoader
            .setSuccessHandler(heroImageReceivedCallback)
            .prepareRequest(urlEndpoint)
            .doGetPhoto()
    }
    
    func setDefaultImage() {
        self.heroImage.image = SinglePokemonViewController.DEFAULT_IMAGE
    }
    
    func heroImageReceivedCallback(image: UIImage) {
        self.heroImage.contentMode = .ScaleAspectFit
        self.heroImage.image = image
        ProgressHud.dismiss()
    }
    
    @IBAction func didTapCommentsButton(sender: UIButton) {
        sender.enabled = false
        ProgressHud.show()
        
        commentRequest
            .setSuccessHandler({ self.displayComments($0, sender: sender) })
            .setFailureHandler({ ProgressHud.indicateFailure() })
            .doGetComments(loggedInUser, pokemonId: pokemon.id)
    }
    
    func displayComments(injecting: CommentList, sender: UIButton) {
        ProgressHud.indicateSuccess()
        
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("commentViewController") as! CommentViewController
        commentViewController.comments = injecting.comments
        commentViewController.pokemon = self.pokemon
        commentViewController.loggedInUser = loggedInUser
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
        sender.enabled = true
    }
    
}