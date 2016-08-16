import UIKit
import Unbox
import Alamofire

class PokemonListViewController: UITableViewController {
    
    var loggedInUser: User!
    var items: [Pokemon]!
    
    private var userDataLocalStorage: UserDataLocalStorage!
    private var userRequest: ApiUserRequest!
    private var listRequest: ApiPokemonListRequest!
    private var serverRequestor: ServerRequestor!
    private var imageRequest: ApiPhotoRequest!
    
    private let imageCache = ImageCache.sharedInstance
    private let requestCache = Cache<UITableViewCell, Request>(maxCacheSize: 50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = Container.sharedInstance
        userDataLocalStorage = container.get(UserDataLocalStorage.self)
        userRequest = container.get(ApiUserRequest.self)
        listRequest = container.get(ApiPokemonListRequest.self)
        serverRequestor = container.get(ServerRequestor.self)
        imageRequest = container.get(ApiPhotoRequest.self)
        
        requestCache.priorToCleanupAction = { request in request.cancel() }
        fetchPokemons()
    }
    
    @IBAction func didPullToRefresh(sender: UIRefreshControl) {
        fetchPokemons()
        sender.endRefreshing()
    }
    
    func fetchPokemons() {
        ProgressHud.show()
        
        listRequest
            .setSuccessHandler(loadPokemons)
            .setFailureHandler({ ProgressHud.indicateFailure("Uh-oh... The Pokemons could not be loaded!")  })
            .doGetPokemons(loggedInUser)
    }
    
    func loadPokemons(pokemonList: PokemonList) {
        ProgressHud.indicateSuccess()
        
        items = pokemonList.pokemons
        tableView.reloadData()
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
        let pokemon = items[indexPath.row]
        let image: UIImage? = nil
        
        let singlePokemonViewController = instantiate(SinglePokemonTableViewController.self, injecting: {
            $0.pokemon = pokemon
            $0.image = image
            $0.loggedInUser = self.loggedInUser
        })
        
        self.navigationController?.pushViewController(singlePokemonViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        stopIfHasRequestInProgress(cell)
    }
    
    func stopIfHasRequestInProgress(cell: UITableViewCell) {
        requestCache
            .getAndClear(cell)
            .ifPresent({ $0.cancel() })
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pokemon = items[indexPath.row]
        let cell = getDefaultCell(pokemon, indexPath: indexPath)
        
        stopIfHasRequestInProgress(cell)
        imageCache
            .get(pokemon.attributes.imageUrl)
            .ifPresent({ cell.pokemonImageUIView.image = $0 })
            .orElseDo({ self.invokeAsyncCellImageUpdate(cell, row: indexPath,
                imageUrl: pokemon.attributes.imageUrl) })
        
        return cell
    }
    
    func getDefaultCell(pokemon: Pokemon, indexPath: NSIndexPath) -> PokemonTableCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonTableCell", forIndexPath: indexPath) as! PokemonTableCell
        
        cell.pokemonNameLabel.text = pokemon.attributes.name
        cell.setDefaultImage()
        
        return cell
    }
    
    func invokeAsyncCellImageUpdate(cell: PokemonTableCell, row: NSIndexPath, imageUrl: String?) {
        Result
            .ofNullable(imageUrl)
            .ifPresent({ self.setCellImage(cell, row: row, imageUrl: $0) })
    }
    
    func setCellImage(cell: PokemonTableCell, row: NSIndexPath, imageUrl: String) {
        let req = imageRequest.prepareRequest(imageUrl).getRequest()
        requestCache.put(cell, value: req)
        
        req.validate()
            .response(completionHandler: { (_, _, data, error) in
                if error == nil {
                    Result
                        .ofNullable(data)
                        .map({ UIImage(data: $0) })
                        .ifPresent({
                            cell.pokemonImageUIView.image = $0
                            self.imageCache.put(imageUrl, value: $0)
                        })
                    self.tableView.reloadData()
                }
            })
    }
    
    override func viewWillDisappear(animated: Bool) {
        requestCache.forEach({ (cell, request) in request.cancel() })
        requestCache.emptyCache()
    }
}


// MARK - Status bar actions

extension PokemonListViewController {
    @IBAction func didTapAddPokemonAction(sender: AnyObject) {
        let createPokemonViewController = instantiate(CreatePokemonViewController.self, injecting: {
            $0.loggedInUser = self.loggedInUser;
            $0.createPokemonDelegate = self
        })
        
        self.navigationController?.pushViewController(createPokemonViewController, animated: true)
    }
    
    @IBAction func didTapLogoutButton(sender: AnyObject) {
        userRequest.doLogout(loggedInUser)
        userDataLocalStorage.deleteActiveUser()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}


// MARK - Delegate for newly created Pokemons

extension PokemonListViewController: CreatePokemonDelegate {
    
    func notify(pokemon: Pokemon, image: UIImage?) {
        items.insert(pokemon, atIndex: 0)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)],
                                         withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
}
