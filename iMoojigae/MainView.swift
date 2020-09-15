//
//  MainView.swift
//  iMooojigae
//
//  Created by dykim on 2020/06/27.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import os.log

class MainView : UITableViewController, HttpSessionRequestDelegate, LoginToServiceDelegate {
    
    //MARK: Properties
    
    var mainData = MainData()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "무지개교육마을"
        // Load the data.
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainData?.menuList.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellMenu = "Menu"
        let cellRecent = "Recent"
        let cellLink = "Link"

        // Fetches the appropriate meal for the data source layout.
        let menuData = mainData?.menuList[indexPath.row]
        var cell: UITableViewCell
        
        if menuData?.type == "recent" {
            cell = tableView.dequeueReusableCell(withIdentifier: cellRecent, for: indexPath)
        } else if menuData?.type == "link" {
            cell = tableView.dequeueReusableCell(withIdentifier: cellLink, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: cellMenu, for: indexPath)
        }

        cell.textLabel?.text = menuData?.title
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "SetView":
            break
        case "Menu":
            guard let boardView = segue.destination as? BoardView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let menuData = mainData?.menuList[indexPath.row]
            boardView.menuName = menuData?.title
            boardView.menuId = menuData?.value
        case "Recent":
            guard let recentView = segue.destination as? RecentView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let menuData = mainData?.menuList[indexPath.row]
            recentView.recent = mainData!.recent
            recentView.type = menuData!.value
        case "Link":
            guard let linkView = segue.destination as? LinkView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let menuData = mainData?.menuList[indexPath.row]
            linkView.linkName = menuData!.title
            linkView.link = menuData!.value
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: - HttpSessionRequestDelegate
    
    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            print("json to Any Error")
            return
        }
        // 원하는 작업
        print(jsonToArray)
        mainData = MainData(json: jsonToArray)
        print(mainData?.recent as Any)
        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
        
        let loginToService = LoginToService()
        loginToService.delegate = self
        loginToService.Login()
    }

    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, withError error: Error) {
    }

    //MARK: - LoginToServiceDelegate
    
    func loginToService(_ loginToService: LoginToService, loginWithSuccess result: String) {
        
    }
    
    func loginToService(_ loginToService: LoginToService, loginWithFail result: String) {
        
    }
    
    func loginToService(_ loginToService: LoginToService, logoutWithSuccess result: String) {
        
    }
    
    func loginToService(_ loginToService: LoginToService, logoutWithFail result: String) {
        
    }
    
    func loginToService(_ loginToService: LoginToService, pushWithSuccess result: String) {
        
    }
    
    func loginToService(_ loginToService: LoginToService, pushWithFail result: String) {
        
    }
    
    
    //MARK: - User Functions
    
    private func loadData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-menu.do?comm=moo_menu", param: nil, referer: "")
    }
}

