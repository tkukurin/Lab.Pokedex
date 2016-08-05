//
//  PokemonTableCell.swift
//  Homework
//
//  Created by Infinum on 8/5/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit

class PokemonTableCell: UITableViewCell {
    
    @IBOutlet weak var pokemonImageUIView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    override func awakeFromNib() {
        initRoundedImage()
    }
    
    func initRoundedImage() {
        self.pokemonImageUIView.layer.cornerRadius = self.pokemonImageUIView.frame.size.width / 2;
        self.pokemonImageUIView.clipsToBounds = true;
        self.pokemonImageUIView.layer.borderWidth = 1.5;
    }
    
    func displayPokemon(pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.attributes.name
        loadImage(pokemon)
    }
    
    func loadImage(pokemon: Pokemon) {
        Result.ofNullable(pokemon.attributes.imageUrl)
            .ifSuccessfulDo({ (url) in
                let fullPath = ServerRequestor.REQUEST_DOMAIN + url
                Container.sharedInstance.getImageLoader().loadFrom(fullPath, callback: self.imageLoadedCallback)
            })
    }
    
    func imageLoadedCallback(image: UIImage?) {
        self.pokemonImageUIView.image = image
    }
    
}
