import UIKit
import Unbox

protocol CreatePokemonDelegate {
    func notify(pokemon: Pokemon, image: UIImage?)
}

class CreatePokemonViewController: UITableViewController {
    
    @IBOutlet weak var imageViewComponent: UIImageView!
    @IBOutlet weak var pokemonNameTextField: UITextField!
    @IBOutlet weak var pokemonHeightTextField: UITextField!
    @IBOutlet weak var pokemonWeightTextField: UITextField!
    @IBOutlet weak var pokemonDescriptionTextField: UITextField!
    
    var user: User!
    var createPokemonDelegate: CreatePokemonDelegate!
    
    private var pickedImage: UIImage!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
        
        pokemonNameTextField.text = "Test pokemon"
        pokemonHeightTextField.text = "12"
        pokemonWeightTextField.text = "22"
        pokemonDescriptionTextField.text = "Test Pokemon description also"
    }
    
    
    @IBAction func didTapAddImageButton(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func didTapCreatePokemonButton(sender: UIButton) {
        constructPokemonAttributeMap()
            .ifPresent({
                ProgressHud.show()
                ApiPokemonCreateRequest()
                    .setSuccessHandler(self.closeWindowAndNotifyDelegate)
                    .doCreate(self.user, image: self.pickedImage, attributes: $0)
            })
    }
    
    func closeWindowAndNotifyDelegate(createdPokemon: Pokemon) -> Void {
        self.navigationController?.popViewControllerAnimated(true)
        self.createPokemonDelegate.notify(createdPokemon,
                                          image: self.imageViewComponent.image)
    }
    
    func constructPokemonAttributeMap() -> Result<[String: String]> {
        var attributes = [String: String]()
        var fieldsAreValid = true
        
        [ (pokemonNameTextField, ApiRequestConstants.PokeAttributes.NAME),
            (pokemonHeightTextField, ApiRequestConstants.PokeAttributes.HEIGHT),
            (pokemonWeightTextField, ApiRequestConstants.PokeAttributes.WEIGHT),
            (pokemonDescriptionTextField, ApiRequestConstants.PokeAttributes.DESCRIPTION) ].forEach({ tuple in
                let key = tuple.1
                let value = tuple.0.text!
                
                if value.isEmpty {
                    fieldsAreValid = false
                    AnimationUtils.shakeFieldAnimation(tuple.0)
                } else {
                    attributes[key] = value
                }
        })
        
        attributes["gender-id"] = "1" // todo
        return Result.ofNullable(fieldsAreValid ? attributes : nil)
    }
    
}

extension CreatePokemonViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewComponent.image = pickedImage
            self.pickedImage = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

