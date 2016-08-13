import UIKit
import Unbox

class SinglePokemonViewController: UIViewController {
    static let DEFAULT_IMAGE = UIImage(named: "Pokeball.png")
    
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
        heightLabel.text = getOrDefaultString(pokemon.attributes.height)
        weightLabel.text = getOrDefaultString(pokemon.attributes.weight)
        genderLabel.text = getOrDefaultString(pokemon.attributes.gender)
        typeLabel.text = getOrDefaultString(pokemon.type)
        Result.ofNullable(self.image)
            .ifSuccessfulDo({ self.heroImage.image = $0 })
            .ifFailedDo({ _ in self.loadImageOrDisplayDefault(self.pokemon.attributes.imageUrl) })
    }
    
    func loadImageOrDisplayDefault(imageUrl: String?) {
        Result
            .ofNullable(imageUrl)
            .ifSuccessfulDo(loadImage)
            .ifFailedDo({ _ in self.heroImage.image = SinglePokemonViewController.DEFAULT_IMAGE })
    }
    
    func getOrDefaultString<T>(value: T) -> String {
        if let value: T = value { return String(value) }
        return "?"
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
        sender.enabled = false
        ProgressHud.show()
        
        serverRequestor.doGet(RequestEndpoint.forComments(pokemon.id),
                              requestingUser: loggedInUser,
                              callback: serverActionCallback)
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
        ProgressHud.indicateSuccess()
        
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("commentViewController") as! CommentViewController
        commentViewController.comments = injecting.comments
        commentViewController.pokemon = self.pokemon
        commentViewController.loggedInUser = loggedInUser
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
    }
    
}