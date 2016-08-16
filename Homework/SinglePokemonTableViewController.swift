
import UIKit

class SinglePokemonTableViewController: UITableViewController {
    typealias TableCellInitializer = (cell: UITableViewCell, row: Int) -> UITableViewCell
    typealias SectionDescriptor = (identifier: String, nItems: Int, initializer: TableCellInitializer)
    
    private static let HERO_IMAGE_HEIGHT: CGFloat = 250.0
    private static let DEFAULT_IMAGE = UIImage(named: "Pokeball.png")
    private static let DEFAULT_STRING_IF_DATA_UNAVAILABLE = "?"
    
    var pokemon : Pokemon!
    var image: UIImage?
    var loggedInUser: User!
    
    private let imageCache = ImageCache.sharedInstance
    
    private var imageLoader: ApiPhotoRequest!
    private var commentRequest: ApiCommentListRequest!
    private var SECTIONS: [SectionDescriptor]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        title = pokemon.attributes.name
        
        SECTIONS = [
            (identifier: "heroImageCell", nItems: 1, initializer: createHeroImageCell),
            (identifier: "pokemonDescriptionCell", nItems: 1, initializer: createPokemonDescriptionCell),
            (identifier: "pokemonAttributeCell", nItems: 4, initializer: createPokemonAttributesCell)
        ]
        
        imageLoader = Container.sharedInstance.get(ApiPhotoRequest.self)
        commentRequest = Container.sharedInstance.get(ApiCommentListRequest.self)
        
        imageCache
            .get(pokemon.attributes.imageUrl)
            .ifPresent(updatePhotoAndCloseProgressHud)
            .orElseDo({ self.loadImageOrDisplayDefault(self.pokemon.attributes.imageUrl) })
    }

    override func viewWillDisappear(animated: Bool) {
        ProgressHud.dismiss()
    }
    
    func loadImageOrDisplayDefault(imageUrl: String?) {
        Result
            .ofNullable(imageUrl)
            .ifPresent(loadImage)
            .orElseDo({ self.updatePhotoAndCloseProgressHud(SinglePokemonTableViewController.DEFAULT_IMAGE) })
    }
    
    func loadImage(urlEndpoint: String) {
        ProgressHud.show()
        
        imageLoader
            .setSuccessHandler({
                self.imageCache.put(self.pokemon.attributes.imageUrl!, value: $0)
                self.updatePhotoAndCloseProgressHud($0)
            })
            .setFailureHandler({
                self.updatePhotoAndCloseProgressHud(SinglePokemonTableViewController.DEFAULT_IMAGE)
            })
            .prepareRequest(urlEndpoint)
            .doGetPhoto()
    }
    
    func updatePhotoAndCloseProgressHud(image: UIImage?) {
        self.image = image
        ProgressHud.dismiss()
        tableView.reloadData()
    }
    
    @IBAction func didTapCommentsButton(sender: UIBarButtonItem) {
        disallowMultipleTaps(sender)
        
        ProgressHud.show()
        commentRequest
            .setSuccessHandler({ self.displayComments($0, sender: sender) })
            .setFailureHandler({ ProgressHud.indicateFailure() })
            .doGetComments(loggedInUser, pokemonId: pokemon.id)
    }
    
    func disallowMultipleTaps(sender: UIBarButtonItem) {
        sender.enabled = false
    }
    
    func displayComments(injecting: CommentList, sender: UIBarButtonItem) {
        ProgressHud.indicateSuccess()
        
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("commentViewController") as! CommentViewController
        commentViewController.comments = injecting.comments
        commentViewController.pokemon = self.pokemon
        commentViewController.loggedInUser = loggedInUser
        
        self.navigationController?.pushViewController(commentViewController, animated: true)
        
        reEnableCommentsButton(sender)
    }
    
    func reEnableCommentsButton(sender: UIBarButtonItem) {
        sender.enabled = true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isHeroImageCell(indexPath) {
            return SinglePokemonTableViewController.HERO_IMAGE_HEIGHT
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func isHeroImageCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SECTIONS.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SECTIONS[section].nItems
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionDescriptor = SECTIONS[indexPath.section]
        let cell = tableView.dequeueReusableCellWithIdentifier(sectionDescriptor.identifier, forIndexPath: indexPath) as UITableViewCell
        
        return sectionDescriptor.initializer(cell: cell, row: indexPath.row)
    }
    
    func createHeroImageCell(cell: UITableViewCell, row: Int) -> UITableViewCell {
        let cell = cell as! PokemonImageTableCell
        cell.pokemonImage.image = self.image
        
        return cell
    }
    
    func createPokemonDescriptionCell(cell: UITableViewCell, row: Int) -> UITableViewCell {
        let cell = cell as! PokemonDescriptionTableCell
        cell.setPokemonNameAndDescription(pokemon.attributes.name, pokemon.attributes.description)
        
        return cell
    }
    
    func createPokemonAttributesCell(cell: UITableViewCell, row: Int) -> UITableViewCell {
        let cell = cell as! PokemonAttributeTableCell
        var key = "", value = ""
        
        switch row {
        case 0:
            key = "Gender"
            value = getOrDefaultFromString(pokemon.attributes.gender)
        case 1:
            key = "Height"
            value = getOrDefaultFromDouble(pokemon.attributes.height)
        case 2:
            key = "Weight"
            value = getOrDefaultFromDouble(pokemon.attributes.weight)
        default:
            key = "Type"
            value = getOrDefaultFromString(pokemon.type)
        }
        
        cell.setKeyValuePair(key, value)
        return cell
    }
    
    func getOrDefaultFromDouble(value: Double?) -> String {
        if let value: Double = value { return String(format:"%.2f", value) }
        return SinglePokemonTableViewController.DEFAULT_STRING_IF_DATA_UNAVAILABLE
    }
    
    func getOrDefaultFromString(value: String?) -> String {
        if let value: String = value { return value }
        return SinglePokemonTableViewController.DEFAULT_STRING_IF_DATA_UNAVAILABLE
    }
    
}
