
import UIKit
import Unbox
import Alamofire

protocol CommentCreatedDelegate {
    func notify(comment: Comment)
}

class CommentViewController: UITableViewController {
    
    var loggedInUser: User!
    var comments: [Comment]!
    var pokemon: Pokemon!
    
    private let requestCache = Cache<UITableViewCell, Request>(maxCacheSize: 30)
    private let usernameCache = Cache<String, String>(maxCacheSize: 30)
    
    private var commentRequest: ApiCommentListRequest!
    private var userRequest: ApiUserRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentRequest = Container.sharedInstance.get(ApiCommentListRequest.self)
        userRequest = Container.sharedInstance.get(ApiUserRequest.self)
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
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        stopIfHasRequestInProgress(cell)
    }
    
    func stopIfHasRequestInProgress(cell: UITableViewCell) {
        requestCache
            .getAndClear(cell)
            .ifPresent({ $0.cancel() })
    }
    
    func getViewCommentCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableCell
        cell.commentLabel.text = comment.attributes?.content
        cell.setDate(comment.attributes?.createdAt)
        
        stopIfHasRequestInProgress(cell)
        usernameCache
            .get(comment.userId)
            .ifPresent({ cell.commenterUsernameLabel.text = $0 })
            .orElseDo({ self.loadUsernameFromServer(cell, userId: comment.userId, indexPath: indexPath) })
        
        return cell
    }
    
    func loadUsernameFromServer(ncell: CommentTableCell, userId: String, indexPath: NSIndexPath) {
        userRequest
            .setSuccessHandler({
                if let cell: CommentTableCell = self.tableView.cellForRowAtIndexPath(indexPath) as? CommentTableCell {
                    let username = $0.attributes.username
                    cell.commenterUsernameLabel.text = username
                }
                
                self.usernameCache.put($0.id, value: $0.attributes.username)
                self.tableView.reloadData()
            })
            .doGet(loggedInUser, userId: userId)
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
