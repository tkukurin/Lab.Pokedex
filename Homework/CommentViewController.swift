
import UIKit
import Unbox

class CommentViewController: UITableViewController {
    
    var serverRequestor: ServerRequestor!
    var loggedInUser: User!
    
    var comments: [Comment]!
    var users: [User]!
    var cells: [CommentTableCell?]!
    
    var pokemon: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        cells = [CommentTableCell?](count: comments.count, repeatedValue: nil)
        getUsernames()
    }
    
    func getUsernames() {
        users = Array(count: comments.count, repeatedValue: loggedInUser)
        
        var index = 0
        comments.forEach({
            let currentIndex = index
            serverRequestor.doGet(RequestEndpoint.forUsers($0.userId ?? ""),
                requestingUser: self.loggedInUser,
                callback: { self.fillCellUsername($0, arrayIndex: currentIndex) })
            index += 1
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? comments.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return displayPostCommentCell(tableView, cellForRowAtIndexPath: indexPath)
        } else {
            return displayCommentDataCell(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    func displayCommentDataCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableCell
        cell.commentLabel.text = comment.attributes?.content
        
        cells[indexPath.row] = cell
        
//        serverRequestor.doGet(RequestEndpoint.forUsers(comment.userId ?? ""),
//                              requestingUser: loggedInUser,
//                              callback: {
//                                $0.ifSuccessfulDo({
//                                    let user: User = try Unbox($0)
//                                    cell.commenterUsernameLabel.text = user.attributes.username
//                                    self.tableView.reloadData()
//                                })
//                              })
        
        return cell
    }
    
    func fillCellUsername(serverResponse: ServerResponse<AnyObject>, arrayIndex: Int) {
        serverResponse
            .ifSuccessfulDo({
                let currentUser: User = try Unbox($0)
                self.cells[arrayIndex]?.commenterUsernameLabel.text = currentUser.attributes.username
                self.tableView.reloadData()
            })
            .ifFailedDo({ _ in ProgressHud.indicateFailure("Well crap. Failed.") })
    }
    
    func displayPostCommentCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCommentCell", forIndexPath: indexPath) as! PostCommentTableCell
        cell.pokemonId = self.pokemon.id
        cell.user = loggedInUser
        return cell
    }
    
    
}
