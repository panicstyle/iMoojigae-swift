//
//  ArticleView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/14.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds

class ArticleView: UIViewController, UITableViewDelegate, UITableViewDataSource, HttpSessionRequestDelegate, WKUIDelegate, WKNavigationDelegate {
    
    //MARK: Properties
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var bannerView: GADBannerView!
    var boardId: String = ""
    var boardNo: String = ""

    var articleData = ArticleData()
    var cellContent: UITableViewCell?
    var webView: WKWebView?
    var dicAttach: Dictionary = [String: String]()
    var contentHeight: CGFloat = 0
    var isDarkMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                print("Light mode")
                self.isDarkMode = false
            } else {
                print("Dark mode")
                self.isDarkMode = true
            }
        } else {
            // Fallback on earlier versions
            self.isDarkMode = false
        }
        
        self.cellContent = UITableViewCell()
        self.webView = WKWebView()
        
        // GoogleMobileAds
        self.bannerView.adUnitID = GlobalConst.AdUnitID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        // Load the data.
        self.loadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        default:
            return self.articleData?.commentList.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return ""
        default:
            return String(self.articleData?.commentList.count ?? 0) + "개의 댓글"
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            } else if indexPath.row == 1 {
                return self.contentHeight
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellTitle = "Title"
        let cellContent = "Content"
        let cellReplay = "Reply"
        let cellReReply = "ReReply"

        var cell: UITableViewCell
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: cellTitle, for: indexPath)
                let textSubject = cell.viewWithTag(101) as! UITextView
                let labelName = cell.viewWithTag(100) as! UILabel
                textSubject.text = self.articleData?.subject
                let name: String = self.articleData?.name ?? ""
                let date: String = self.articleData?.date ?? ""
                let hit: String = self.articleData?.hit ?? ""
                labelName.text = name + " " + date + " " + hit + "명 읽음"
            } else {
                self.cellContent = tableView.dequeueReusableCell(withIdentifier: cellContent, for: indexPath)
                cell = self.cellContent!
                cell.addSubview(self.webView!)
            }
        default:
            let commentList = self.articleData!.commentList
            let item = commentList[indexPath.row]
            if item.isRe == "1" {
                cell = tableView.dequeueReusableCell(withIdentifier: cellReplay, for: indexPath)
                let labelName = cell.viewWithTag(200) as! UILabel
                let viewComment = cell.viewWithTag(202) as! UITextView
                labelName.text = item.name + " " + item.date
                viewComment.text = item.comment
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: cellReReply, for: indexPath)
                let labelName = cell.viewWithTag(300) as! UILabel
                let viewComment = cell.viewWithTag(302) as! UITextView
                labelName.text = item.name + " " + item.date
                viewComment.text = item.comment
            }
        }
        return cell
    }
    
    // MARK: - WKWebViewDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let titleFont = UIFont.preferredFont(forTextStyle: .body)
        let pointSize: Int = Int(Double(titleFont.pointSize / 17.0) * 100);
        let fontSize = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '" + String(pointSize) + "%%'"
        let padding = "document.body.style.padding='0px 8px 0px 8px';"
        let calcSize = "document.body.scrollHeight;"
        self.webView?.evaluateJavaScript(padding, completionHandler: nil)
        self.webView?.evaluateJavaScript(fontSize, completionHandler: nil)
        self.webView?.evaluateJavaScript(calcSize, completionHandler: { (object, error) in
            let result = object as? NSNumber ?? 0
            if result == 0 {
                return
            }
            if (self.cellContent == nil) {
                return
            }
            self.contentHeight = CGFloat(truncating: result)
            var contentRect: CGRect = self.cellContent!.frame
            contentRect.size.height = self.contentHeight
            self.cellContent!.frame = contentRect
            
            var webRect: CGRect = self.webView!.frame
            webRect.size.height = self.contentHeight
            self.webView!.frame = webRect
            
            self.tableView.reloadData()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - HttpSessionRequestDelegate
    
    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            print("json to Any Error")
            return
        }
        // 원하는 작업
        NSLog("%@", jsonToArray)
        self.articleData = ArticleData(json: jsonToArray)
        DispatchQueue.main.sync {
            self.makeWebContent(httpSessionRequest)
            self.tableView.reloadData()
        }
    }

    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, withError error: Error) {
    }

    //MARK: Private Methods
    
    private func loadData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.requestWithParam(httpMethod: "GET", resource: GlobalConst.ServerName + "/board-api-read.do?boardId=" + boardId + "&boardNo=" + self.boardNo + "&command=READ&page=1&categoryId=-1&rid=20", param: nil, referer: "")
    }
    
    func makeWebContent(_ httpSessionRequest:HttpSessionRequest) {
        var strImage: String = ""
        let imageList = self.articleData?.imageList
        for item in imageList! {
            let fileName = item.fileName.lowercased()
            if fileName.contains(".jpg") || fileName.contains(".jpeg")
            || fileName.contains(".png") || fileName.contains(".gif") {
                strImage = strImage + item.link
            }
        }
        strImage = strImage.replacingOccurrences(of: "<img ", with: "<img onclick=\"myapp_clickImg(this)\" width=300 ")

        var strAttach: String = ""
        let attachList = self.articleData?.attachList
        if attachList!.count > 0 {
            strAttach = strAttach + "<table boader=1><tr><th>첨부파일</th></tr>"
        }
        for item in attachList! {
            strAttach = strAttach + "<tr><td>" + item.link + "</td></tr>"
            self.dicAttach.updateValue(item.fileSeq, forKey: item.fileName)
        }
        if attachList!.count > 0 {
            strAttach = strAttach + "</table>"
        }
        
        var strProfile: String = ""
        strProfile = strProfile + "<div class='profile'>" + self.articleData!.profile + "</div>"
        
        var strContent: String = self.articleData!.content
        strContent = strContent.replacingOccurrences(of: "<img ", with: "<img onclick=\"myapp_clickImg(this)\" width=300 ")
        
        let strDarModeCss: String = """
        <style type="text/css">
        @media (prefers-color-scheme: dark) { \
            body { \
                background-color: rgb(38,38,41);
                color: white;
            }
            a:link {
                color: #0096e2;
            }
            a:visited {
                color: #9d57df;
            }
        }
        </style>
        """
        
        var strHtml: String = ""
        strHtml += "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
        strHtml += "<html><head>"
        strHtml += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
        strHtml += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=medium-dpi\">"
        strHtml += "<script>function myapp_clickImg(obj){window.location=\"jscall://\"+encodeURIComponent(obj.src);}</script>"
        if self.isDarkMode {
            strHtml += strDarModeCss
        }
        strHtml += "</head><body>"
        strHtml += strContent
        strHtml += strImage
        strHtml += strAttach
        strHtml += "<hr>"
        strHtml += strProfile
        strHtml += "</body></html>"
        
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        //쿠키를 담을 배열 sharedCookies
        if httpSessionRequest.sharedCookies!.count > 0 {
            //sharedCookies에서 쿠키들을 뽑아내서 wkDataStore에 넣는다.
            for cookie in httpSessionRequest.sharedCookies! {
                wkDataStore.httpCookieStore.setCookie(cookie){}
            }
        }
        
        let baseUrl = URL(string: GlobalConst.ServerName)
        let config = WKWebViewConfiguration()
        config.websiteDataStore = wkDataStore
        
        self.webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: (self.cellContent?.frame.size.width)!, height: (self.cellContent?.frame.size.height)!), configuration: config)
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.webView?.backgroundColor = .clear
        self.webView?.isOpaque = false
        self.webView?.loadHTMLString(strHtml, baseURL: baseUrl)
    }
    
}
