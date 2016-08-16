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
    
    var loggedInUser: User!
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
            .ifPresent({ attributes in
                ProgressHud.show()
                self.pokemonCreateRequest
                    .setSuccessHandler(self.closeWindowAndNotifyDelegate)
                    .setFailureHandler({ ProgressHud.indicateFailure() })
                    .doCreate(self.loggedInUser, image: self.pickedImage, attributes: attributes)
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
        
        getTuplesOfFieldAndAttributeKey().forEach({ tuple in
            let key = tuple.key
            let field = tuple.field
            
            Result.ofNullable(field)
                .map({ $0.text })
                .filter({ !$0.isEmpty })
                .ifPresent({ attributes[key] = $0 })
                .orElseDo({ fieldsAreValid = false; AnimationUtils.shakeFieldAnimation(field) })
        })
        
        attributes[ApiRequestConstants.PokeAttributes.GENDER_ID] = getGenderIdFromSegmentControl()
        return Result.ofNullable(fieldsAreValid ? attributes : nil)
    }
    
    func getTuplesOfFieldAndAttributeKey() -> [(key: String, field: UITextField)] {
        return [ (key: ApiRequestConstants.PokeAttributes.NAME, field: pokemonNameTextField),
                 (key: ApiRequestConstants.PokeAttributes.HEIGHT, field: pokemonHeightTextField),
                 (key: ApiRequestConstants.PokeAttributes.WEIGHT, field: pokemonWeightTextField),
                 (key: ApiRequestConstants.PokeAttributes.DESCRIPTION, field: pokemonDescriptionTextField) ]
    }
    
    func getGenderIdFromSegmentControl() -> String {
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

