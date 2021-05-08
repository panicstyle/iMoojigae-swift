//
//  ReceviceData.swift
//  iMooojigae
//
//  Created by dykim on 2020/08/19.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation
import UIKit

extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}

//MARK: - SetStorage

@objc(SetStorage) class SetStorage: NSObject, NSCoding {
    var userId: NSString
    var userPwd: NSString
    var swPush: NSNumber

    init(userId: String, userPwd: String, swPush: NSNumber) {
        self.userId = userId as NSString
        self.userPwd = userPwd as NSString
        self.swPush = swPush
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: "id")
        aCoder.encode(userPwd, forKey: "pwd")
        aCoder.encode(swPush, forKey: "push")
    }

    required init?(coder aDecoder: NSCoder) {
        userId = aDecoder.decodeObject(forKey: "id") as! NSString
        userPwd = aDecoder.decodeObject(forKey: "pwd") as! NSString
        swPush = aDecoder.decodeObject(forKey: "push") as! NSNumber
        super.init()
    }
}

//MARK: - SetTokenStorage

@objc(SetTokenStorage) class SetTokenStorage: NSObject, NSCoding {
    var token: NSString

    init(token: String) {
        self.token = token as NSString
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: "token")
    }

    required init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObject(forKey: "token") as! NSString
        super.init()
    }
}

//MARK: - MainData

struct  MenuData {
    var title: String = ""
    var type: String = ""
    var value: String = ""
}

struct MainData {
    var menuList = [MenuData]()
    var recent: String = ""
    
    init?() {
        return nil
    }
    
    init?(json: [String: Any]) {
        guard
            !json.isEmpty,
            let menu = json["menu"] as? [[String: Any]],
            let recent = json["recent"] as? String
        else {
            return nil
        }
        for menuIndex in menu {
            var menuData = MenuData()
            menuData.title = menuIndex["title"] as! String
            menuData.type = menuIndex["type"] as! String
            menuData.value = menuIndex["value"] as! String
            self.menuList.append(menuData)
        }
        self.recent = recent
    }
}

//MARK: - BoardData

struct  Board {
    var title: String = ""
    var type: String = ""
    var boardId: String = ""
}

struct BoardData {
    var boardList = [Board]()
    var recent: String = ""
    var new: String = ""

    init?() {
        return nil
    }
    
    init?(json: [String: Any]) {
        // The name must not be empty
        guard !json.isEmpty else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if json.isEmpty  {
            return nil
        }
        guard
            let menu = json["menu"] as? [[String: Any]],
            let recent = json["recent"] as? String,
            let new = json["new"] as? String
        else {
            return nil
        }
        for menuIndex in menu {
            var board = Board()
            board.title = menuIndex["title"] as! String
            board.type = menuIndex["type"] as! String
            board.boardId = menuIndex["boardId"] as! String
            self.boardList.append(board)
        }
        self.recent = recent
        self.new = new
    }
}

//MARK: - ItemsData

struct  Item {
    var boardNo: String = ""
    var isNew: Int = 0
    var isUpdated: Int = 0
    var isRe: String = ""
    var boardId: String = ""
    var subject: String = ""
    var name: String = ""
    var comment: String = ""
    var hit: String = ""
    var date: String = ""
    var read: Int = 0
}

struct ItemData {
    var itemList = [Item]()

    init?() {
        return nil
    }
    
    init?(json: [String: Any]) {
        // The name must not be empty
        guard !json.isEmpty else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if json.isEmpty  {
            return nil
        }
        guard
            let items = json["item"] as? [[String: Any]]
        else {
            return nil
        }
        let db = DBInterface()
        for itemIndex in items {
            var item = Item()
            item.boardNo = itemIndex["boardNo"] as! String
            let recentArticle = itemIndex["recentArticle"] as! String
            if recentArticle == "Y" {
                item.isNew = 1
            }
            let updatedArticle = itemIndex["updatedArticle"] as! String
            if updatedArticle == "Y" {
                item.isUpdated = 1
            }
            item.isRe = itemIndex["boardDep"] as! String
            item.boardId = itemIndex["boardId"] as! String
            item.subject = itemIndex["boardTitle"] as! String
            item.name = itemIndex["userNick"] as! String
            item.comment = itemIndex["boardMemo_cnt"] as! String
            item.hit = itemIndex["boardRead_cnt"] as! String
            item.date = itemIndex["boardRegister_dt"] as! String

            item.read = 0
            if db.search(boardId: item.boardId, boardNo: item.boardNo) > 0 {
                item.read = 1
            }
            self.itemList.append(item)
        }
    }
}

//MARK: - RecentItemsData

struct  RecentItem {
    var boardNo: String = ""
    var isNew: Int = 0
    var isUpdated: Int = 0
    var boardId: String = ""
    var boardName: String = ""
    var subject: String = ""
    var name: String = ""
    var comment: String = ""
    var hit: String = ""
    var date: String = ""
    var read: Int = 0
}

struct RecentItemData {
    var itemList = [RecentItem]()

    init?() {
        return nil
    }
    
    init?(json: [String: Any]) {
        // The name must not be empty
        guard !json.isEmpty else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if json.isEmpty  {
            return nil
        }
        guard
            let items = json["item"] as? [[String: Any]]
        else {
            return nil
        }
        let db = DBInterface()
        for itemIndex in items {
            var item = RecentItem()
            item.boardNo = itemIndex["boardNo"] as! String
            let recentArticle = itemIndex["recentArticle"] as! String
            if recentArticle == "Y" {
                item.isNew = 1
            }
            let updatedArticle = itemIndex["updatedArticle"] as! String
            if updatedArticle == "Y" {
                item.isUpdated = 1
            }
            item.boardId = itemIndex["boardId"] as! String
            item.boardName = itemIndex["boardName"] as! String
            item.subject = itemIndex["boardTitle"] as! String
            item.name = itemIndex["userNick"] as! String
            item.comment = itemIndex["boardMemo_cnt"] as! String
            item.hit = itemIndex["boardRead_cnt"] as! String
            item.date = itemIndex["boardRegister_dt"] as! String
            
            item.read = 0
            if db.search(boardId: item.boardId, boardNo: item.boardNo) > 0 {
                item.read = 1
            }
            self.itemList.append(item)
        }
    }
}

struct  CommentItem {
    var isRe: String = ""
    var no: String = ""
    var name: String = ""
    var date: String = ""
    var comment: String = ""
}

struct  ImageItem {
    var fileName: String = ""
    var link: String = ""
}

struct  AttachItem {
    var fileName: String = ""
    var fileSeq: String = ""
    var link: String = ""
}

struct ArticleData {
    var subject: String = ""
    var name: String = ""
    var date: String = ""
    var hit: String = ""
    var content: String = ""
    var profile: String = ""
    var commentList = [CommentItem]()
    var imageList = [ImageItem]()
    var attachList = [AttachItem]()

    init?() {
        return nil
    }
    
    init?(json: [String: Any]) {
        // The name must not be empty
        guard !json.isEmpty else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if json.isEmpty  {
            return nil
        }
        guard
            let boardTitle = json["boardTitle"] as? String,
            let userNick = json["userNick"] as? String,
            let boardRegister_dt = json["boardRegister_dt"] as? String,
            let boardRead_cnt = json["boardRead_cnt"] as? String,
            let boardContent = json["boardContent"] as? String,
            let userComment = json["userComment"] as? String,
            let memo = json["memo"] as? [[String: Any]],
            let image = json["image"] as? [[String: Any]],
            let attachment = json["attachment"] as? [[String: Any]]
        else {
            return nil
        }
        self.subject = boardTitle
        self.name = userNick
        self.date = boardRegister_dt
        self.hit = boardRead_cnt
        self.content = boardContent
        self.profile = userComment
        for itemIndex in memo {
            var item = CommentItem()
            item.isRe = itemIndex["memoDep"] as! String
            item.no = itemIndex["memoSeq"] as! String
            item.name = itemIndex["userNick"] as! String
            item.date = itemIndex["memoRegister_dt"] as! String
            item.comment = itemIndex["memoContent"] as! String
            self.commentList.append(item)
        }
        for itemIndex in image {
            var item = ImageItem()
            item.fileName = itemIndex["fileName"] as! String
            item.link = itemIndex["link"] as! String
            self.imageList.append(item)
        }
        for itemIndex in attachment {
            var item = AttachItem()
            item.fileName = itemIndex["fileName"] as! String
            item.fileSeq = itemIndex["fileSeq"] as! String
            item.link = itemIndex["link"] as! String
            self.attachList.append(item)
        }
    }
}
