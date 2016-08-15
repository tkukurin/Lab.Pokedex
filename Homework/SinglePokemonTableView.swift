
import UIKit

class SinglePokemonTableView: UITableViewController {
    static let HERO_IMAGE_HEIGHT: CGFloat = 250.0
    static let DEFAULT_IMAGE = UIImage(named: "Pokeball.png")
    static let DEFAULT_STRING_IF_DATA_UNAVAILABLE = "?"
    
    var pokemon : Pokemon!
    var image: UIImage?
    
    var loggedInUser: User!
    private var imageLoader: ApiPhotoRequest!
    private var commentRequest: ApiCommentListRequest!
    
    typealias SectionDescription = (identifier: String,
                                    nItems: Int,
                                    initializer: (cell: UITableViewCell, row: Int) -> UITableViewCell)
    private var SECTIONS: [SectionDescription]!
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        SECTIONS = [
            (identifier: "heroImageCell", nItems: 1, initializer: createHeroImageCell),
            (identifier: "pokemonDescriptionCell", nItems: 1, initializer: createPokemonDescriptionCell),
            (identifier: "pokemonAttributeCell", nItems: 4, initializer: createPokemonAttributesCell)
        ]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isHeroImageCell(indexPath) {
            return SinglePokemonTableView.HERO_IMAGE_HEIGHT
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
        return cell as! PokemonImageTableCell
    }
    
    func createPokemonDescriptionCell(cell: UITableViewCell, row: Int) -> UITableViewCell {
        return cell as! PokemonDescriptionTableCell
    }
    
    func createPokemonAttributesCell(cell: UITableViewCell, row: Int) -> UITableViewCell {
        let cell = cell as! PokemonAttributeTableCell
        
        switch row {
        case 1: cell.textLabel?.text = "Gender"; cell.detailTextLabel?.text = "Some"
        case 2: cell.textLabel?.text = "Height"; cell.detailTextLabel?.text = "Some"
        case 3: cell.textLabel?.text = "Weight"; cell.detailTextLabel?.text = "Some"
        default: cell.textLabel?.text = "Type"; cell.detailTextLabel?.text = "Some"
        }
        
        return cell
    }
    
}

class PokemonImageTableCell: UITableViewCell {
    
    @IBOutlet weak var pokemonImage: UIImageView!
    
    override func awakeFromNib() {
        pokemonImage.image = SinglePokemonTableView.DEFAULT_IMAGE
    }
    
}

class PokemonDescriptionTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        self.nameLabel.text = "Bulbasaur test label"
        self.descriptionLabel.text = "And a description, too. The description will now become much much much much much much longer. The description will now become much much much much much much longer."
    }
}

class PokemonAttributeTableCell: UITableViewCell {
    
    override func awakeFromNib() {
        self.textLabel?.text = "Attribute"
    }
    
}
