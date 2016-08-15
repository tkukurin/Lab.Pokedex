
import UIKit

class SinglePokemonTableView: UITableViewController {
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return tableView.dequeueReusableCellWithIdentifier("description", forIndexPath: indexPath) as! PokemonDescriptionTableCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier("attributes", forIndexPath: indexPath) as! PokemonAttributeTableCell
        }
        
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
