//
//  BoardView.swift
//  iMoojigae
//
//  Created by dykim on 2020/08/27.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import os.log
import WebKit
import GoogleMobileAds

class BoardView : CommonBannerView, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties

    @IBOutlet var tableView : UITableView!
    var menuName: String = ""
    var menuId: String = ""
    
    var boardData = BoardData()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = menuName
        
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
        return boardData?.boardList.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let titleFont = UIFont.preferredFont(forTextStyle: .body)
        let cellHeight: CGFloat = 44.0 - 17.0 + titleFont.pointSize
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIRecent = "Recent"
        let cellIBoard = "Board"
        let cellILink = "Link"

        let cell: UITableViewCell
        let board = boardData?.boardList[indexPath.row]
        if board!.type == "recent" {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIRecent, for: indexPath)
        } else if board!.type == "link" {
            cell = tableView.dequeueReusableCell(withIdentifier: cellILink, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIBoard, for: indexPath)
        }

        cell.textLabel?.text = board?.title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "Board":
            guard let itemView = segue.destination as? ItemView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let board = self.boardData?.boardList[indexPath.row]
            itemView.boardTitle = board!.title
            itemView.boardType = board!.type
            itemView.boardId = board!.boardId
        case "Recent":
            guard let recentView = segue.destination as? RecentView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            recentView.recent = self.boardData!.recent
            recentView.type = "list"
        case "Link":
            guard let linkView = segue.destination as? LinkView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let board = self.boardData?.boardList[indexPath.row]
            linkView.linkName = board!.title
            linkView.link = board!.boardId
            linkView.config = config
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
        NSLog("%@", jsonToArray)
        boardData = BoardData(json: jsonToArray)
        if let boardRecent: String = boardData?.recent {
            NSLog("%@", boardRecent)
        }
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
    }

    //MARK: Private Methods
    
    private func loadData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-menu.do?comm=" + self.menuId, param: nil, referer: "")
    }
}
