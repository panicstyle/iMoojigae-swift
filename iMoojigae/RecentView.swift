//
//  RecentView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/14.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RecentView: CommonBannerView, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    
    @IBOutlet var tableView : UITableView!
    var recent: String = ""
    var type: String = ""
    private let refreshControl = UIRefreshControl()
    
    var itemList = [RecentItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        self.title = "최신글보기"
        
        // Load the data.
        loadMenuData()
    }

    @objc override func contentSizeCategoryDidChangeNotification() {
        self.tableView.reloadData()
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        // Load the data.
        loadData()
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifierItem = "Item"

        var cell: UITableViewCell
        let item = itemList[indexPath.row]

        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierItem, for: indexPath)

        // Fetches the appropriate meal for the data source layout.
        let textSubject: UITextView = cell.viewWithTag(101) as! UITextView
        let labelBoardName: UILabel = cell.viewWithTag(102) as! UILabel
        let labelName: UILabel = cell.viewWithTag(100) as! UILabel
        let labelComment: UILabel = cell.viewWithTag(103) as! UILabel

        if item.comment == "" || item.comment == "0" {
            labelComment.isHidden = true
        } else {
            labelComment.isHidden = false
            labelComment.layer.cornerRadius = 8
            labelComment.layer.borderWidth = 2.0;
            let cnt = Int(item.comment) ?? 1
            if cnt < 10 {
                labelComment.textColor = Utils.hexStringToUIColor(hex: "0B84FF")
            } else {
                labelComment.textColor = Utils.hexStringToUIColor(hex: "30D158")
            }
            labelComment.layer.borderColor = labelComment.textColor.cgColor;
        }
        let subject = String(htmlEncodedString: item.subject) ?? ""
        textSubject.text = subject
        labelBoardName.text = item.boardName
        labelName.text = item.name + " " + item.date
        labelComment.text = item.comment

        if item.read == 1 {
            textSubject.textColor = .gray
        } else {
            if #available(iOS 13.0, *) {
                textSubject.textColor = .label
            } else {
                textSubject.textColor = .black
            }
        }

        textSubject.font = bodyFont
        labelBoardName.font = footnoteFont
        labelName.font = footnoteFont
        labelComment.font = footnoteFont
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = itemList[indexPath.row]
        item.read = 1
        itemList[indexPath.row] = item
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.endUpdates()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "Article":
            guard let articleView = segue.destination as? ArticleView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let item = self.itemList[indexPath.row]
            articleView.boardId = item.boardId
            articleView.boardNo = item.boardNo
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    //MARK: - HttpSessionRequestDelegate
    
    override func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        if httpSessionRequest.tag == GlobalConst.RECENT_MENU_DATA {
            guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                print("json to Any Error")
                return
            }
            
            // 원하는 작업
            let mainData = MainData(json: jsonToArray)
            print(mainData?.recent as Any)
            self.recent = mainData?.recent ?? ""
            DispatchQueue.main.sync {
                self.loadData()
            }
        } else {
            guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                print("json to Any Error")
                self.refreshControl.endRefreshing()
                return
            }
            // 원하는 작업
            NSLog("jsonToArray\n%@", jsonToArray)
            let recentItemData = RecentItemData(json: jsonToArray)
            itemList = recentItemData!.itemList
            DispatchQueue.main.sync {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    //MARK: Private Methods
    
    private func loadMenuData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.RECENT_MENU_DATA
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-menu.do?comm=moo2_menu", param: nil, referer: "")
    }

    private func loadData() {
        let doLink: String = "board-api-recent.do"
        
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.RECENT_ITEM_DATA
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/" + doLink + "?park=index&rid=50&pid=" + self.recent, param: nil, referer: "")
    }
}
