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
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    var user: User!
    var createPokemonDelegate: CreatePokemonDelegate!
    
    private var pickedImage: UIImage!
    private var pokemonCreateRequest: ApiPokemonCreateRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonCreateRequest = Container.sharedInstance.get(ApiPokemonCreateRequest.self)
        
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
                self.pokemonCreateRequest
                    .setSuccessHandler(self.closeWindowAndNotifyDelegate)
                    .setFailureHandler({ ProgressHud.indicateFailure() })
                    .doCreate(self.user, image: self.pickedImage, attributes: $0)
            })
    }
    
    func closeWindowAndNotifyDelegate(createdPokemon: PokemonCreatedResponse) -> Void {
        ProgressHud.indicateSuccess()
        self.navigationController?.popViewControllerAnimated(true)
        self.createPokemonDelegate.notify(createdPokemon.pokemon,
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
        
        attributes[ApiRequestConstants.PokeAttributes.GENDER_ID] = getGenderFromSegment()
        
        return Result.ofNullable(fieldsAreValid ? attributes : nil)
    }
    
    func getGenderFromSegment() -> String {
        let index = genderSegmentedControl.selectedSegmentIndex
        let zeroBasedIndexToValidOneBasedGenderId = index + 1
        
        return String(zeroBasedIndexToValidOneBasedGenderId)
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

