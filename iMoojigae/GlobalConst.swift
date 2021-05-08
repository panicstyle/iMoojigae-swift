//
//  GlobalConst.swift
//  iMoojigae
//
//  Created by dykim on 2020/08/19.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation

class GlobalConst {
    static var userId = ""
    static var swPush = false
    
    static let ServerName = "https://jumin.moojigae.or.kr"
    static let AdUnitID = "ca-app-pub-9032980304073628/9510593996"
    
    static let LOGIN_TO_SERVER = 1
    static let PUSH_REGISTER = 2
    static let PUSH_UPDATE = 3
    static let LOGOUT_TO_SERVER = 4
    
    static let FILE_TYPE_HTML = 0
    static let FILE_TYPE_IMAGE = 1
    
    static let WRITE_MODE = 0
    static let MODIFY_MODE = 1
    static let REPLY_MODE = 2
    
    static let POST_FILE = 1
    static let POST_DATA = 2
    
    static let SCALE_SIZE = 600
    
    static let READ_ARTICLE = 1
    static let DELETE_ARTICLE = 2
    static let DELETE_COMMENT = 3
    
    static let RECENT_MENU_DATA = 1
    static let RECENT_ITEM_DATA = 2
}
