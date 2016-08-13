import UIKit
import Unbox
import Alamofire

class PokemonListViewController: UITableViewController {
    
    var user: User!
    var items: [(pokemon: Pokemon, image: UIImage?)?]!
    var nLoadedItems: Int!
    
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localStorageAdapter = Container.sharedInstance.getLocalStorageAdapter()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        nLoadedItems = 0
        fetchPokemons()
        
        // @debug
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
            .ifSuccessfulDo(loadPokemonsFromServerResponse)
            .ifFailedDo({ _ in ProgressHud.indicateFailure("Uh-oh... The Pokemons could not be loaded!") })
    }
    
    func loadPokemonsFromServerResponse(data: NSData) throws {
        let fetchedData: PokemonList = try Unbox(data)
        items = [(pokemon: Pokemon, image: UIImage?)?](count: fetchedData.pokemons.count, repeatedValue: nil)
        
        getImages(fetchedData.pokemons)
        ProgressHud.indicateSuccess()
    }
    
    func getImages(pokemons: [Pokemon]) {
        (0..<pokemons.count).forEach({ i in
            self.items[i] = (pokemons[i], nil)
            
            Result
                .ofNullable(pokemons[i].attributes.imageUrl)
                .ifSuccessfulDo({
                    Alamofire
                        .request(.GET, ServerRequestor.REQUEST_DOMAIN + RequestEndpoint.forImages($0))
                        .validate()
                        .response(completionHandler: { (_, _, data, _) in
                            Result
                                .ofNullable(data)
                                .ifSuccessfulDo({
                                    self.items[i]?.image = UIImage(data: $0)
                                    
                                    self.nLoadedItems = self.nLoadedItems.successor()
                                    if self.nLoadedItems == self.items.count {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.tableView.reloadData()
                                        })
                                    }
                                })
                        })
                }).ifFailedDo({ _ in
                    self.nLoadedItems = self.nLoadedItems.successor()
                    if self.nLoadedItems == self.items.count {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                })
        })
        
        self.tableView.reloadData()
    }
    
    func updateCommentsTable(forIndex: Int) {
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: forIndex, inSection: 0)],
                                         withRowAnimation: .Automatic)
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
        let pokemon = items[indexPath.row]?.pokemon
        let image = items[indexPath.row]?.image
        
        let singlePokemonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("singlePokemonViewController")
            as! SinglePokemonViewController
        
        singlePokemonViewController.pokemon = pokemon
        singlePokemonViewController.image = image
        singlePokemonViewController.loggedInUser = user
        
        self.navigationController?.pushViewController(singlePokemonViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonTableCell", forIndexPath: indexPath) as! PokemonTableCell
        
        cell.displayPokemon((items[indexPath.row]?.pokemon)!,
                            image: items[indexPath.row]?.image)
        
        return cell
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
        navigationController?.popViewControllerAnimated(true)
    }
}


// MARK - Delegate for newly created Pokemons

extension PokemonListViewController: CreatePokemonDelegate {
    
    func notify(pokemon: Pokemon, image: UIImage?) {
        items.insert((pokemon: pokemon, image: image), atIndex: 0)
        updateCommentsTable(0)
    }
    
}
