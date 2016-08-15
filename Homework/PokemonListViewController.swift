import UIKit
import Unbox
import Alamofire

class PokemonListViewController: UITableViewController {
    
    var user: User!
    var items: [Pokemon]!
    
    private var localStorageAdapter: LocalStorageAdapter!
    private var serverRequestor: ServerRequestor!
    private let requestCache = Cache<UITableViewCell, Request>(maxCacheSize: 500)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localStorageAdapter = Container.sharedInstance.get(LocalStorageAdapter.self)
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
        
        fetchPokemons()
    }
    
    func fetchPokemons() {
        ProgressHud.show()
        ApiPokemonListRequest()
            .setSuccessHandler(loadPokemons)
            .setFailureHandler({ ProgressHud.indicateFailure("Uh-oh... The Pokemons could not be loaded!")  })
            .doGetPokemons(user)
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
        
        let singlePokemonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("singlePokemonViewController")
            as! SinglePokemonViewController
        
        singlePokemonViewController.pokemon = pokemon
        singlePokemonViewController.image = image
        singlePokemonViewController.loggedInUser = user
        
        self.navigationController?.pushViewController(singlePokemonViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        stopIfHasRequestInProgress(cell)
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pokemon = items[indexPath.row]
        let cell = getDefaultCell(pokemon, indexPath: indexPath)
        
        stopIfHasRequestInProgress(cell)
        
        Result
            .ofNullable(pokemon.attributes.imageUrl)
            .ifPresent({ self.updateCellImage(cell, row: indexPath, imageUrl: $0) })
        
        return cell
    }
    
    func getDefaultCell(pokemon: Pokemon, indexPath: NSIndexPath) -> PokemonTableCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonTableCell", forIndexPath: indexPath) as! PokemonTableCell
        
        cell.pokemonNameLabel.text = pokemon.attributes.name
        cell.setDefaultImage()
        
        return cell
    }
    
    func stopIfHasRequestInProgress(cell: UITableViewCell) {
        requestCache
            .getAndClear(cell)
            .ifPresent({ $0.cancel() })
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
        navigationController?.popViewControllerAnimated(true)
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
