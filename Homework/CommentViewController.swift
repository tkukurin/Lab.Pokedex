//
//  CommentViewController.swift
//  Homework
//
//  Created by toni-user on 12/08/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import UIKit
import Unbox

class CommentViewController: UITableViewController {
    
    var serverRequestor: ServerRequestor!
    var loggedInUser: User!
    
    var items: CommentList!
    var pokemon: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverRequestor = Container.sharedInstance.getServerRequestor()
        
        print(self.items)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? items.comments.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            print("sec 2")
            let cell = tableView.dequeueReusableCellWithIdentifier("postCommentCell", forIndexPath: indexPath) as! PostCommentTableCell
            cell.pokemonId = self.pokemon.id
            cell.user = loggedInUser
            return cell
        }
        
        let comment = items.comments[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableCell
        cell.setComment("asdf", comment: comment)
        
//        serverRequestor.doGet(RequestKeys.User,
//                              requestingUser: loggedInUser,
//                              callback: { data in displayCell(cell, comment, data) })
        
        return cell
    }
    
//    func displayCell(cell: UITableViewCell, comment: Comment, data: NSData) {
//        Result
//            .ofNullable(try? Unbox(data))
//        cell.displayComment(comment)
//    }
    
}
