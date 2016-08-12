//
//  UserList.swift
//  Homework
//
//  Created by toni-user on 12/08/16.
//  Copyright © 2016 Infinum. All rights reserved.
//

import Unbox

struct UserList: Unboxable {
    let users: [User]
    
    init(unboxer: Unboxer) {
        users = unboxer.unbox(RequestKeys.User.DATA_PREFIX)
    }
}