import UIKit

class PokemonImageTableCell: UITableViewCell {
    
    @IBOutlet weak var pokemonImage: UIImageView!
    
}

class PokemonDescriptionTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setPokemonNameAndDescription(name: String?, _ description: String?) {
        self.nameLabel.text = name
        self.descriptionLabel.text = description
    }
}

class PokemonAttributeTableCell: UITableViewCell {
    
    func setKeyValuePair(key: String, _ value: String) {
        self.textLabel?.text = key
        self.detailTextLabel?.text = value
    }
    
}