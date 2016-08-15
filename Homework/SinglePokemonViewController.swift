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
    
    var imageLoader: UrlImageLoader!
    var loggedInUser: User!
    var serverRequestor: ServerRequestor!
    var alertUtils: AlertUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLoader = Container.sharedInstance.getImageLoader()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        
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
            .orElseDo({ _ in self.loadImageOrDisplayDefault(self.pokemon.attributes.imageUrl) })
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
        
        let fullPath = ServerRequestor.REQUEST_DOMAIN + urlEndpoint
        imageLoader.loadFrom(fullPath, callback: heroImageReceivedCallback)
    }
    
    func setDefaultImage(ignorable: Exception) {
        self.heroImage.image = SinglePokemonViewController.DEFAULT_IMAGE
    }
    
    func heroImageReceivedCallback(image: UIImage?) {
        Result
            .ofNullable(image)
            .ifPresent({
                self.heroImage.contentMode = .ScaleAspectFit
                self.heroImage.image = $0
            })
        ProgressHud.dismiss()
    }
    
    @IBAction func didTapCommentsButton(sender: UIButton) {
        sender.enabled = false
        ProgressHud.show()
        
        serverRequestor.doGet(RequestEndpoint.forComments(pokemon.id),
                              requestingUser: loggedInUser,
                              callback: serverActionCallback)
    }
    
    func serverActionCallback(serverResponse: ServerResponse<AnyObject>) {
        serverResponse
            .ifPresent(loadAndDisplayComments)
            .orElseDo({ _ in ProgressHud.indicateFailure() })
    }
    
    func loadAndDisplayComments(commentData: NSData) {
        Result
            .ofNullable(commentData)
            .map({ (data: NSData) in return (try Unbox(data) as CommentList) })
            .ifPresent(displayComments)
            //.ifPresent(loadUsersForCommentsAndDisplay)
            .orElseDo({ _ in ProgressHud.indicateFailure("Error loading comments!") })
    }
    
    func loadUsersForCommentsAndDisplay(commentList: CommentList) {
        var usersForComments = [User?](count: commentList.comments.count, repeatedValue: nil)
        var index = 0
        
        commentList.comments.forEach({
            self.serverRequestor.doGet(RequestEndpoint.forUsers($0.userId!),
                requestingUser: self.loggedInUser,
                callback: { $0.ifPresent({ usersForComments[index] = try Unbox($0) as User }) })
            index += 1
        })
    }
    
    func displayComments(injecting: CommentList) {
        ProgressHud.indicateSuccess()
        
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("commentViewController") as! CommentViewController
        commentViewController.comments = injecting.comments
        commentViewController.pokemon = self.pokemon
        commentViewController.loggedInUser = loggedInUser
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
    }
    
}