//
//  BoardView.swift
//  iMoojigae
//
//  Created by dykim on 2020/08/27.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import os.log

class BoardView : UITableViewController, HttpSessionRequestDelegate {
    
    //MARK: Properties
    
    var menuName: String? = ""
    var menuId: String? = ""
    var boardData = BoardData()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = menuName
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
        return boardData?.boardList.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            
        case "Board":
            guard let itemView = segue.destination as? ItemView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let board = self.boardData?.boardList[indexPath.row]
            itemView.boardTitle = board?.title
            itemView.boardType = board?.type
            itemView.boardId = board?.boardId
        case "Recent":
            guard let recentView = segue.destination as? RecentView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            recentView.recent = self.boardData!.recent
            recentView.type = "list"
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
        boardData = BoardData(json: jsonToArray)
        if let boardRecent: String = boardData?.recent {
            NSLog("%@", boardRecent)
        }
        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
    }

    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, withError error: Error) {
    }

    //MARK: Private Methods
    
    private func loadData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-menu.do?comm=" + menuId!, param: nil, referer: "")
    }
}
