import UIKit
import Unbox

protocol CreatePokemonDelegate {
    func notify(pokemon: Pokemon, image: UIImage?)
}

class CreatePokemonViewController: UIViewController {
    
    @IBOutlet weak var imageViewComponent: UIImageView!
    @IBOutlet weak var pokemonNameTextField: UITextField!
    @IBOutlet weak var pokemonHeightTextField: UITextField!
    @IBOutlet weak var pokemonWeightTextField: UITextField!
    @IBOutlet weak var pokemonDescriptionTextField: UITextField!
    
    var user: User!
    var createPokemonDelegate: CreatePokemonDelegate!
    
    private var pickedImage: UIImage!
    private var alertUtils: AlertUtils!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        pokemonNameTextField.text = "Test pokemon"
        pokemonHeightTextField.text = "12"
        pokemonWeightTextField.text = "22"
        pokemonDescriptionTextField.text = "Test Pokemon description also"
    }
    
    @IBAction func didTapGetImageButton(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapCreatePokemonButton(sender: UIButton) {
        Result
            .ofNullable(constructPokemonAttributeMap())
            .ifSuccessfulDo({
                ProgressHud.show()
                self.serverRequestor.doMultipart(RequestEndpoint.POKEMON_ACTION,
                    user: self.user,
                    pickedImage: self.pickedImage,
                    attributes: $0,
                    callback: self.serverActionCallback)
            })
    }
    
    func constructPokemonAttributeMap() -> [String: String]? {
        var attributes = [String: String]()
        var fieldsAreValid = true
        
        [ (pokemonNameTextField, RequestKeys.PokeAttributes.NAME),
            (pokemonHeightTextField, RequestKeys.PokeAttributes.HEIGHT),
            (pokemonWeightTextField, RequestKeys.PokeAttributes.WEIGHT),
            (pokemonDescriptionTextField, RequestKeys.PokeAttributes.DESCRIPTION) ].forEach({ tuple in
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
        return fieldsAreValid ? attributes : nil
    }
    
}

extension CreatePokemonViewController {
    
    func serverActionCallback(response: ServerResponse<String>?) -> Void {
        guard let response = response else {
            ProgressHud.indicateFailure()
            return
        }
        
        response.ifSuccessfulDo({
            let pokemonCreatedResponse: PokemonCreatedResponse = try Unbox($0)
            
            ProgressHud.indicateSuccess("Successfully created pokemon!")
            self.navigationController?.popViewControllerAnimated(true)
            self.createPokemonDelegate.notify(pokemonCreatedResponse.pokemon,
                image: self.imageViewComponent.image)
        }).ifFailedDo({ _ in
            ProgressHud.indicateFailure()
        })
    }
    
}


extension CreatePokemonViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //imageViewComponent.contentMode = .ScaleAspectFit
            imageViewComponent.image = pickedImage
            
//            let subView = UIImageView(image: pickedImage)
//            imageViewComponent.addSubview(subView)
            self.pickedImage = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

