//
//  ItemsView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/12.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit

class ItemView: UITableViewController, HttpSessionRequestDelegate {
    
    //MARK: Properties
    
    var boardTitle: String? = ""
    var boardType: String? = ""
    var boardId: String? = ""
    var itemList = [Item]()
    var nPage: Int = 1
    var isEndPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = boardTitle
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
        let cellIdentifierReItem = "ReItem"
//        let cellIdentifierMore = "More"

        var cell: UITableViewCell
        let item = itemList[indexPath.row]
        let isRe = Int(item.isRe)
        if isRe == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierItem, for: indexPath)
            // Fetches the appropriate meal for the data source layout.
            let textSubject: UITextView = cell.viewWithTag(101) as! UITextView
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
            labelName.text = item.name + " " + item.date
            labelComment.text = item.comment
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierReItem, for: indexPath)
            // Fetches the appropriate meal for the data source layout.
            let textSubject: UITextView = cell.viewWithTag(301) as! UITextView
            let labelName: UILabel = cell.viewWithTag(300) as! UILabel
            let labelComment: UILabel = cell.viewWithTag(303) as! UILabel
            textSubject.text = item.subject
            labelName.text = item.name + " " + item.date
            labelComment.text = item.comment
        }
//        print ("indexPath.row=\(indexPath.row), itemList.count=\(itemList.count)")
        if indexPath.row  == (itemList.count - 1) {
            if !isEndPage {
                nPage = nPage + 1
                loadData()
            }
        }
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
        NSLog("%@", jsonToArray)
        let itemData = ItemData(json: jsonToArray)
        if itemData!.itemList.count > 0 {
            if nPage == 1 {
                itemList = itemData!.itemList
            } else {
                itemList.append(contentsOf: itemData!.itemList)
            }
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        } else {
            isEndPage = true
        }
    }

    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, withError error: Error) {
    }

    //MARK: Private Methods
    
    private func loadData() {
        let sPage: String = String(nPage)
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-list.do?boardId=" + boardId! + "&page=" + sPage, param: nil, referer: "")
    }
}
