//
//  RecentView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/14.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit

class RecentView: UITableViewController, HttpSessionRequestDelegate {

    var recent: String = ""
    var type: String = ""
    var itemList = [RecentItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.type == "list" {
            self.title = "최신글보기"
        } else {
            self.title = "최신댓글보기"
        }
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifierItem = "Item"

        var cell: UITableViewCell
        let item = itemList[indexPath.row]

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
            labelComment.layer.borderWidth = 1.0;
            labelComment.layer.borderColor = labelComment.textColor.cgColor;
        }
        textSubject.text = item.subject
        labelBoardName.text = item.boardName
        labelName.text = item.name + " " + item.date
        labelComment.text = item.comment

        return cell
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
    
    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            print("json to Any Error")
            return
        }
        // 원하는 작업
        NSLog("jsonToArray\n%@", jsonToArray)
        let recentItemData = RecentItemData(json: jsonToArray)
        itemList = recentItemData!.itemList
        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
    }

    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, withError error: Error) {
    }

    //MARK: Private Methods
    
    private func loadData() {
        var doLink: String = "board-api-recent-memo.do"
        if self.type == "list" {
            doLink = "board-api-recent.do"
        }
        
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/" + doLink + "?park=index&rid=50&pid=" + self.recent, param: nil, referer: "")
    }
    
}