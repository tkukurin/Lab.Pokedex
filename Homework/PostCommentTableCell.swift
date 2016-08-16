
import UIKit

class PostCommentTableCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    private var apiCommentPostRequest: ApiCommentPostRequest!
    
    var pokemonId: Int!
    var user: User!
    var delegate: CommentCreatedDelegate!
    
    override func awakeFromNib() {
        apiCommentPostRequest = Container.sharedInstance.get(ApiCommentPostRequest.self)
    }
    
    @IBAction func didTapSendButton(sender: AnyObject) {
        Result
            .ofNullable(textField.text)
            .filter({ !$0.isEmpty })
            .ifPresent(postComment)
            .orElseDo({
                AnimationUtils.shakeFieldAnimation(self.textField)
            })
    }
    
    func postComment(content: String) {
        apiCommentPostRequest
            .setSuccessHandler(commentCreatedCallback)
            .setFailureHandler({ ProgressHud.indicateFailure("Couldn't post comment!") })
            .doPostComment(user, pokemonId: pokemonId, content: content)
    }
    
    func commentCreatedCallback(commentCreatedResponse: CommentCreatedResponse) {
        self.textField.text = ""
        self.resignFirstResponder()
        
        delegate.notifyCommentCreated(commentCreatedResponse.comment)
    }
    
}
