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

class MainView : CommonBannerView, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    
    @IBOutlet var tableView : UITableView!
    
    var mainData = MainData()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "게시판"
        
        let db = DBInterface()
        db.delete()
        
        // Load the data.
        loadData()
    }
    @objc override func contentSizeCategoryDidChangeNotification() {
        self.tableView.reloadData()
    }
    
    //MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainData?.menuList.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let titleFont = UIFont.preferredFont(forTextStyle: .body)
        let cellHeight: CGFloat = 44.0 - 17.0 + titleFont.pointSize
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        case "Menu":
            guard let boardView = segue.destination as? BoardView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let menuData = mainData?.menuList[indexPath.row]
            boardView.menuName = menuData!.title
            boardView.menuId = menuData!.value
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
            linkView.config = config
        case "About":
            guard segue.destination is AboutView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: - HttpSessionRequestDelegate
    
    override func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            print("json to Any Error")
            return
        }
        
        // 원하는 작업
        print(jsonToArray)
        mainData = MainData(json: jsonToArray)
        print(mainData?.recent as Any)
        DispatchQueue.main.sync {
            // Cookie 처리
            let wkDataStore = WKWebsiteDataStore.nonPersistent()
            //쿠키를 담을 배열 sharedCookies
            if httpSessionRequest.sharedCookies!.count > 0 {
                //sharedCookies에서 쿠키들을 뽑아내서 wkDataStore에 넣는다.
                for cookie in httpSessionRequest.sharedCookies! {
                    wkDataStore.httpCookieStore.setCookie(cookie){}
                }
            }
            config = WKWebViewConfiguration()
            config!.websiteDataStore = wkDataStore
            
            self.tableView.reloadData()
        }
        
        let loginToService = LoginToService()
        loginToService.delegate = self
        loginToService.Login()
    }

    //MARK: - LoginToServiceDelegate
    
    //MARK: - User Functions
    
    private func loadData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-menu.do?comm=moo2_menu", param: nil, referer: "")
    }
}

