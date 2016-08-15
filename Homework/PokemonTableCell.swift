
import UIKit

class PokemonTableCell: UITableViewCell {
    static let DEFAULT_IMAGE = UIImage(named: "Pokeball.png")
    
    @IBOutlet weak var pokemonImageUIView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    override func awakeFromNib() {
        initRoundedImage()
    }
    
    func setDefaultImage() {
        self.pokemonImageUIView.image = PokemonTableCell.DEFAULT_IMAGE
    }
    
    func initRoundedImage() {
        pokemonImageUIView.layer.masksToBounds = false
        pokemonImageUIView.layer.borderColor = UIColor.grayColor().CGColor
        pokemonImageUIView.layer.borderWidth = 0.5
        pokemonImageUIView.layer.cornerRadius = pokemonImageUIView.frame.size.width / 2;
        pokemonImageUIView.clipsToBounds = true;
    }
    
}
