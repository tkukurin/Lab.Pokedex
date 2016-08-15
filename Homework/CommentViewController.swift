
import UIKit
import Unbox
import Alamofire

protocol CommentCreatedDelegate {
    func notify(comment: Comment)
}

class CommentViewController: UITableViewController {
    
    var serverRequestor: ServerRequestor!
    var loggedInUser: User!
    
    var comments: [Comment]!
    var cells: [CommentTableCell?]!
    
    var pokemon: Pokemon!
    
    private let cache = Cache<UITableViewCell, Request>(maxCacheSize: 30)
    private var commentRequest: ApiCommentRequest!
    private var userRequest: ApiUserRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
        commentRequest = Container.sharedInstance.get(ApiCommentRequest.self)
        userRequest = Container.sharedInstance.get(ApiUserRequest.self)
        
        tableView.reloadData()
    }
    
    func updateCommentsTable(forIndex: Int) {
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: forIndex, inSection: 0)],
                                         withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? comments.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 { return getPostCommentCell(tableView, cellForRowAtIndexPath: indexPath) }
        else { return getViewCommentCell(tableView, cellForRowAtIndexPath: indexPath) }
    }
    
    func getViewCommentCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableCell
        cell.commentLabel.text = comment.attributes?.content
        cell.setDate(comment.attributes?.createdAt)
        
        cache
            .getAndClear(cell)
            .ifPresent({ $0.cancel() })
        userRequest
            .setSuccessHandler({ cell.commenterUsernameLabel.text = $0.attributes.username })
            .setFailureHandler({ cell.commenterUsernameLabel.text = "unknown commenter" })
            .doGet(loggedInUser, userId: comment.userId)
        
        return cell
    }
    
    func getPostCommentCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCommentCell", forIndexPath: indexPath) as! PostCommentTableCell
        cell.pokemonId = self.pokemon.id
        cell.user = loggedInUser
        cell.delegate = self
        return cell
    }
    
}

extension CommentViewController : CommentCreatedDelegate {
    func notify(comment: Comment) {
        comments.append(comment)
        updateCommentsTable(comments.count - 1)
    }
}
