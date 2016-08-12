import UIKit
import Unbox

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
    var loggedInUser: User!
    var serverRequestor: ServerRequestor!
    var alertUtils: AlertUtils!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLoader = Container.sharedInstance.getImageLoader()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        
        title = pokemon.attributes.name
        loadPokemonData(pokemon)
    }
    
    override func viewWillDisappear(animated: Bool) {
        ProgressHud.dismiss()
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
        
        // TODO requestendpoint.resolveImageUrl
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
    
    @IBAction func didTapCommentsButton(sender: UIButton) {
        serverRequestor.doGet(RequestEndpoint.forComments(pokemon.id), requestingUser: loggedInUser, callback: serverActionCallback)
    }
    
    func serverActionCallback(serverResponse: ServerResponse<AnyObject>) {
        serverResponse
            .ifSuccessfulDo(loadAndDisplayComments)
            .ifFailedDo({ _ in ProgressHud.indicateFailure() })
    }
    
    func loadAndDisplayComments(commentData: NSData) {
        Result
            .ofNullable(commentData)
            .map({ (data: NSData) in return (try Unbox(data) as CommentList) })
            .ifSuccessfulDo(displayComments)
            //.ifSuccessfulDo(loadUsersForCommentsAndDisplay)
            .ifFailedDo({ _ in ProgressHud.indicateFailure("Error loading comments!") })
    }
    
    func loadUsersForCommentsAndDisplay(commentList: CommentList) {
        var usersForComments = [User?](count: commentList.comments.count, repeatedValue: nil)
        var index = 0
        
        commentList.comments.forEach({
            self.serverRequestor.doGet(RequestEndpoint.forUsers($0.userId!),
                requestingUser: self.loggedInUser,
                callback: { $0.ifSuccessfulDo({ usersForComments[index] = try Unbox($0) as User }) })
            index += 1
        })
    }
    
    func displayComments(injecting: CommentList) {
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("commentViewController") as! CommentViewController
        commentViewController.comments = injecting.comments
        commentViewController.pokemon = self.pokemon
        commentViewController.loggedInUser = loggedInUser
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
    }
    
}