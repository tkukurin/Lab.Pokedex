//
//  PokemonTableCell.swift
//  Homework
//
//  Created by Infinum on 8/5/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit

class PokemonTableCell: UITableViewCell {
    static let DEFAULT_CELL = UIImage(named: "Pokeball.png")
    
    @IBOutlet weak var pokemonImageUIView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    override func awakeFromNib() {
        initRoundedImage()
    }
    
    func initRoundedImage() {
        pokemonImageUIView.layer.masksToBounds = false
        pokemonImageUIView.layer.borderColor = UIColor.grayColor().CGColor
        pokemonImageUIView.layer.borderWidth = 0.5
        pokemonImageUIView.layer.cornerRadius = pokemonImageUIView.frame.size.width / 2;
        pokemonImageUIView.clipsToBounds = true;
    }
    
    func displayPokemon(pokemon: Pokemon, image: UIImage?) {
        pokemonNameLabel.text = pokemon.attributes.name
        Result
            .ofNullable(image)
            .ifSuccessfulDo({ self.pokemonImageUIView.image = $0 })
            .ifFailedDo({ _ in self.pokemonImageUIView.image = PokemonTableCell.DEFAULT_CELL })
    }
    
}
