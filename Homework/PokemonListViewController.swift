import UIKit
import Unbox
import Alamofire

class PokemonListViewController: UITableViewController {
    static let DEFAULT_IMAGE = UIImage(named: "Pokeball.png")
    
    var user: User!
    var items: [Pokemon]!
    var nLoadedItems: Int!
    
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    
    //private var activeRequests: [Int: Request]!
    private let requestCache = Cache<UITableViewCell, Request>(maxCacheSize: 500)
    //private let cache = Cache<UITableViewCell, (request: Request, image: UIImage?)>(maxCacheSize: 500)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localStorageAdapter = Container.sharedInstance.getLocalStorageAdapter()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        //activeRequests = [Int: Request]()
        
        nLoadedItems = 0
        fetchPokemons()
        
        print("auth header: \(user.attributes.authToken)")
    }
    
    func fetchPokemons() {
        ProgressHud.show()
        
        serverRequestor.doGet(
            RequestEndpoint.POKEMON_ACTION,
            requestingUser: user,
            callback: pokemonServerRequestCallback)
    }
    
    func pokemonServerRequestCallback(response: ServerResponse<AnyObject>) {
        response
            .ifPresent(loadPokemonsFromServerResponse)
            .orElseDo({ _ in ProgressHud.indicateFailure("Uh-oh... The Pokemons could not be loaded!") })
    }
    
    func loadPokemonsFromServerResponse(data: NSData) throws {
        let fetchedData: PokemonList = try Unbox(data)
        items = fetchedData.pokemons
        
        ProgressHud.indicateSuccess()
        tableView.reloadData()
    }
    
    func updateCommentsTable(forIndex: NSIndexPath) {
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([forIndex], withRowAnimation: .Left)
        tableView.endUpdates()
    }
}


// MARK - TableView specific methods

extension PokemonListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pokemon = items[indexPath.row] //.pokemon
        let image: UIImage? = nil
        
        let singlePokemonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("singlePokemonViewController")
            as! SinglePokemonViewController
        
        singlePokemonViewController.pokemon = pokemon
        singlePokemonViewController.image = image
        singlePokemonViewController.loggedInUser = user
        
        self.navigationController?.pushViewController(singlePokemonViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        requestCache
            .get(cell)
            .ifPresent({ $0.cancel() })
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pokemon = items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonTableCell", forIndexPath: indexPath) as! PokemonTableCell
        
        cell.pokemonNameLabel.text = pokemon.attributes.name
        cell.setDefaultImage()
        
        requestCache.get(cell)
            .ifPresent({ $0.cancel() })
        
        Result
            .ofNullable(pokemon.attributes.imageUrl)
            .ifPresent({ self.updateCellImage(cell, row: indexPath, imageUrl: $0) })
        
        return cell
    }
    
    func updateCellImage(cell: PokemonTableCell, row: NSIndexPath, imageUrl: String?) {
        Result
            .ofNullable(imageUrl)
            .ifPresent({ self.setCellImage(cell, row: row, imageUrl: $0) })
    }
    
    func setCellImage(cell: PokemonTableCell, row: NSIndexPath, imageUrl: String) {
        let req = Alamofire.request(.GET, ServerRequestor.REQUEST_DOMAIN + RequestEndpoint.forImages(imageUrl))
        
        requestCache.store(cell, value: req)
        req.validate()
            .response(completionHandler: { (_, _, data, error) in
                if error == nil {
                    Result
                        .ofNullable(data)
                        .ifPresent({
                            let image = UIImage(data: $0)
                            cell.pokemonImageUIView.image = image
                        })
                }
            })
    }
}


// MARK - Status bar actions

extension PokemonListViewController {
    @IBAction func didTapAddPokemonAction(sender: AnyObject) {
        let createPokemonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("createPokemonViewController") as! CreatePokemonViewController
        
        createPokemonViewController.user = user
        createPokemonViewController.createPokemonDelegate = self
        
        self.navigationController?.pushViewController(createPokemonViewController, animated: true)
    }
    
    @IBAction func didTapLogoutButton(sender: AnyObject) {
        serverRequestor.doDelete(RequestEndpoint.USER_ACTION_CREATE_OR_DELETE)
        localStorageAdapter.deleteActiveUser()
        
        //activeRequests.forEach({ (i, request) in request.cancel() })
        navigationController?.popViewControllerAnimated(true)
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        activeRequests.forEach({ (i, request) in request.cancel() })
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        activeRequests.forEach({ (i, request) in request.resume() })
//    }
}


// MARK - Delegate for newly created Pokemons

extension PokemonListViewController: CreatePokemonDelegate {
    
    func notify(pokemon: Pokemon, image: UIImage?) {
        // items.insert((pokemon: pokemon, image: image), atIndex: 0)
        items.insert(pokemon, atIndex: 0)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)],
                                         withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
}
