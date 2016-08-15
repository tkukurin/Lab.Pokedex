
import UIKit
import Unbox

protocol CommentCreatedDelegate {
    func notify(comment: Comment)
}

class CommentViewController: UITableViewController {
    
    var serverRequestor: ServerRequestor!
    var loggedInUser: User!
    
    var comments: [Comment]!
    var users: [User?]!
    var cells: [CommentTableCell?]!
    
    var pokemon: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverRequestor = Container.sharedInstance.get(ServerRequestor.self)
        cells = [CommentTableCell]()
        
        getUsernames()
    }
    
    func getUsernames() {
        self.users = [User?]()
        
//        (0..<comments.count).forEach({ i in
//            serverRequestor.doGet(RequestEndpoint.forUsers(self.comments[i].userId ?? ""),
//                requestingUser: self.loggedInUser,
//                callback: appendCell)
//        })
    }
    
//    func appendCell(serverResponse: ServerResponse<AnyObject>) {
//        serverResponse
//            .ifPresent({
//                let user: User = try Unbox($0)
//                self.users.append(user)
//                self.updateCommentsTable(self.users.count - 1)
//            })
//    }
    
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
        return section == 0 ? users.count : 1
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
        
        if users.count > indexPath.row {
            cell.commenterUsernameLabel.text = users[indexPath.row]?.attributes.username
        }
        
        cells.append(cell)
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
        users.append(loggedInUser)
        
        let nUsers = users.count
        updateCommentsTable(nUsers - 1)
    }
}
