//
//  ReceviceData.swift
//  iMooojigae
//
//  Created by dykim on 2020/08/19.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation

struct  MenuData {
    var title: String?
    var type: String?
    var value: String?
}

struct MainMenu {
    var menuList = [MenuData]()
    var recent: String?
    
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
            let recent = json["recent"] as? String
        else {
            return nil
        }
        for menuIndex in menu {
            var menuData = MenuData()
            menuData.title = menuIndex["title"] as? String
            menuData.type = menuIndex["type"] as? String
            menuData.value = menuIndex["value"] as? String
            self.menuList.append(menuData)
        }
        self.recent = recent
    }
}

