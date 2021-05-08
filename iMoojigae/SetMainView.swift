//
//  MainView.swift
//  iMooojigae
//
//  Created by dykim on 2020/06/27.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import os.log
import WebKit
import GoogleMobileAds

class SetMainView : CommonBannerView, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    
    @IBOutlet var tableView : UITableView!
    
    var menuList = [MenuData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "설정"
        
        // Load the data.
        loadData()
        self.tableView.reloadData()
    }

    @objc override func contentSizeCategoryDidChangeNotification() {
        self.tableView.reloadData()
    }

    //MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count 
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let titleFont = UIFont.preferredFont(forTextStyle: .body)
        let cellHeight: CGFloat = 44.0 - 17.0 + titleFont.pointSize
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellSetView = "SetView"
        let cellAbout = "About"

        // Fetches the appropriate meal for the data source layout.
        let menuData = menuList[indexPath.row]
        var cell: UITableViewCell
        
        if menuData.value == "SetView" {
            cell = tableView.dequeueReusableCell(withIdentifier: cellSetView, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: cellAbout, for: indexPath)
        }

        cell.textLabel?.text = menuData.title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        return cell
    }
    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "SetView":
            break
        case "About":
            break
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: - User Functions
    
    private func loadData() {
        var menuData = MenuData()
        menuData.title = "설정"
        menuData.value = "SetView"
        menuList.append(menuData)

        menuData = MenuData()
        menuData.title = "앱정보"
        menuData.value = "About"
        menuList.append(menuData)
        
        print(menuList)
    }
}

