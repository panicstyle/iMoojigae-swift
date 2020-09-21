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

protocol ArticleViewDelegate {
    func articleView(_ articleView: ArticleView, didDelete row: Int)
}

class ArticleView: UIViewController, UITableViewDelegate, UITableViewDataSource, HttpSessionRequestDelegate, WKUIDelegate, WKNavigationDelegate, UIDocumentInteractionControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var btnMenu: UIBarButtonItem!
    var boardId: String = ""
    var boardNo: String = ""
    var delegate: ArticleViewDelegate?
    var selectedRow = 0

    var articleData = ArticleData()
    var cellContent: UITableViewCell?
    var webView: WKWebView?
    var dicAttach: Dictionary = [String: String]()
    var contentHeight: CGFloat = 0
    var isDarkMode: Bool = false
    var strHtml: String = ""
    var webLinkType: Int = 0
    var webLink: String = ""
    var doic: UIDocumentInteractionController?
    var config: WKWebViewConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.contentSizeCategoryDidChangeNotification),
                                               name: UIContentSizeCategory.didChangeNotification, object: nil)
        
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
        
        self.btnMenu.target = self
        self.btnMenu.action = #selector(self.articleMenu)
        
        // GoogleMobileAds
        self.bannerView.adUnitID = GlobalConst.AdUnitID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        // Load the data.
        self.loadData()
    }

    @objc func contentSizeCategoryDidChangeNotification() {
        let baseUrl = URL(string: GlobalConst.ServerName)
        self.webView?.loadHTMLString(strHtml, baseURL: baseUrl)
        self.tableView.reloadData()
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

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
        
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
        
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
                
                textSubject.font = bodyFont
                labelName.font = footnoteFont
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
                
                labelName.font = footnoteFont
                viewComment.font = bodyFont
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: cellReReply, for: indexPath)
                let labelName = cell.viewWithTag(300) as! UILabel
                let viewComment = cell.viewWithTag(302) as! UITextView
                labelName.text = item.name + " " + item.date
                viewComment.text = item.comment

                labelName.font = footnoteFont
                viewComment.font = bodyFont
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < 1 {
            return
        }
        let commentList = self.articleData!.commentList
        let item = commentList[indexPath.row]
        let alertTitle = "\(item.name)님의 댓글"
        
        let alert: UIAlertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        let delete: UIAlertAction = UIAlertAction(title: "댓글삭제", style: .default, handler: { (alert: UIAlertAction!) in
            print("delete")
            self.deleteCommentConfirm(item)
        })
        let reply: UIAlertAction = UIAlertAction(title: "댓글답변", style: .default, handler: { (alert: UIAlertAction!) in
            print("reply")
            self.WriteReComment(item)
        })
        let copy: UIAlertAction = UIAlertAction(title: "댓글복사", style: .default, handler: { (alert: UIAlertAction!) in
            print("copy")
            self.copyComment(item)
        })
        let share: UIAlertAction = UIAlertAction(title: "댓글공유", style: .default, handler: { (alert: UIAlertAction!) in
            print("share")
            self.shareComment(item)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .default, handler: { (alert: UIAlertAction!) in
            print("cancelAction")
        })
        alert.addAction(delete)
        alert.addAction(reply)
        alert.addAction(copy)
        alert.addAction(share)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url: URL? = navigationAction.request.url
        var urlString: String? = url?.absoluteString ?? ""
        urlString = urlString?.removingPercentEncoding ?? ""
        let rangeKey = urlString!.range(of: #"(?<=&c=).*?(?=&)"#, options: .regularExpression)

        var keySub: Substring = ""
        var key: String = ""
        var fileName: String = ""
        var loweredExt: String = ""

        if rangeKey != nil {
            keySub = urlString![rangeKey!]
            key = String(keySub)
            fileName = self.dicAttach[key] ?? ""
            loweredExt = fileName.fileExtension().lowercased()
        }
        
        let validImageExt: Set<String> = ["tif", "tiff", "jpg", "jpeg", "gif", "png", "bmp", "bmpf", "ico", "cur", "xbm"]
        
        if (navigationAction.navigationType == WKNavigationType.linkActivated) {
            if validImageExt.contains(loweredExt) {
                self.webLinkType = GlobalConst.FILE_TYPE_IMAGE
                self.webLink = urlString ?? ""
                self.performSegue(withIdentifier: "Link", sender: self)
            } else if loweredExt.count > 0 {    // 확장자가 있으면
                let tempData = NSData.init(contentsOf: url!)
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDir = paths[0]
                let filePath = documentDir.appendingPathComponent(fileName)
                let isWrite = tempData?.write(to: filePath, atomically: true)
                if isWrite != nil && isWrite! {
                    self.doic = UIDocumentInteractionController.init(url: filePath)
                    self.doic?.delegate = self
                    self.doic?.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else {
                UIApplication.shared.open(url!, options: [:])
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        } else if (navigationAction.navigationType == WKNavigationType.other) {
            if urlString!.hasPrefix("jscall:") {
                let url: URL? = navigationAction.request.url
                let urlString: String? = url?.absoluteString ?? ""
                let componets = urlString!.components(separatedBy: "://")
                if componets.count > 0 {
                    let functionName = componets[1]
                    let fileName = functionName.removingPercentEncoding ?? ""
                    self.webLinkType = GlobalConst.FILE_TYPE_IMAGE
                    self.webLink = fileName
                    self.performSegue(withIdentifier: "Link", sender: self)
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    return
                }
            } else if validImageExt.contains(loweredExt) {
                self.webLinkType = GlobalConst.FILE_TYPE_IMAGE
                self.webLink = urlString ?? ""
                self.performSegue(withIdentifier: "Link", sender: self)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else if loweredExt.count > 0 {
                let tempData = NSData.init(contentsOf: url!)
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDir = paths[0]
                let filePath = documentDir.appendingPathComponent(fileName)
                let isWrite = tempData?.write(to: filePath, atomically: true)
                if isWrite != nil && isWrite! {
                    self.doic = UIDocumentInteractionController.init(url: filePath)
                    self.doic?.delegate = self
                    self.doic?.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else {
                decisionHandler(WKNavigationActionPolicy.allow)
                return
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
        return
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "Link":
            guard let linkView = segue.destination as? LinkView else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            linkView.linkName = ""
            linkView.type = self.webLinkType
            linkView.link = self.webLink
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    //MARK: - HttpSessionRequestDelegate
    
    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        if httpSessionRequest.tag == GlobalConst.READ_ARTICLE {
            readArticleFinish(httpSessionRequest, data)
        } else if httpSessionRequest.tag == GlobalConst.DELETE_ARTICLE {
            deleteArticleFinish(httpSessionRequest, data)
        } else {
            deleteCommentFinish(httpSessionRequest, data)
        }
    }

    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, withError error: Error) {
    }

    //MARK: - Private Methods
    
    private func loadData() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.READ_ARTICLE
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
            self.dicAttach.updateValue(item.fileName, forKey: item.fileSeq)
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
        
        strHtml = ""
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
        config = WKWebViewConfiguration()
        config!.websiteDataStore = wkDataStore
        
        self.webView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: (self.cellContent?.frame.size.width)!, height: (self.cellContent?.frame.size.height)!), configuration: config!)
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.webView?.backgroundColor = .clear
        self.webView?.isOpaque = false
        self.webView?.loadHTMLString(strHtml, baseURL: baseUrl)
    }
    
    @objc func articleMenu() {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let writeComment: UIAlertAction = UIAlertAction(title: "댓글쓰기", style: .default, handler: { (alert: UIAlertAction!) in
            print("writeComment")
        })
        let modify: UIAlertAction = UIAlertAction(title: "글수정", style: .default, handler: { (alert: UIAlertAction!) in
            print("modify")
        })
        let delete: UIAlertAction = UIAlertAction(title: "글삭제", style: .default, handler: { (alert: UIAlertAction!) in
            print("delete")
            self.deleteArticleConfirm()
        })
        let showOneBrowser: UIAlertAction = UIAlertAction(title: "웹브라우저로 보기", style: .default, handler: { (alert: UIAlertAction!) in
            print("showOneBrowser")
            let link = GlobalConst.ServerName + "/board-read.do?boardId=" + self.boardId + "&boardNo=" + self.boardNo + "&command=READ&page=1&categoryId=-1&rid=20"
            guard let url = URL(string: "\(link)") else {
                print("URL is nil")
                return
            }
            UIApplication.shared.open(url, options: [:])
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .default, handler: { (alert: UIAlertAction!) in
            print("cancelAction")
        })
        alert.addAction(writeComment)
        alert.addAction(modify)
        alert.addAction(delete)
        alert.addAction(showOneBrowser)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteArticleConfirm() {
        let alert = UIAlertController(title: "삭제하시곘습니까?", message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { (action) in
            self.deleteArticle()
        }
        let cancel = UIAlertAction(title: "취소", style: .default) { (action) in }
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteArticle() {
        let bodyString = "boardId=\(boardId)&page=1&categoryId=-1&time=1334217622773&returnBoardNo=\(boardNo)&boardNo=\(boardNo)&command=DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1"
        
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.DELETE_ARTICLE
        httpSessionRequest.requestWithParamString(httpMethod: "POST", resource: "\(GlobalConst.ServerName)/board-save.do", paramString: bodyString, referer: "\(GlobalConst.ServerName)/board-read.do")
        
    }
    
    func readArticleFinish(_ httpSessionRequest: HttpSessionRequest, _ data: Data) {
        guard let jsonToArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            print("json to Any Error")
            return
        }
        // 원하는 작업
        NSLog("%@", jsonToArray)
        self.articleData = ArticleData(json: jsonToArray)
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
            
            self.makeWebContent(httpSessionRequest)
            self.tableView.reloadData()
        }
    }
    
    func deleteArticleFinish(_ httpSessionRequest: HttpSessionRequest, _ data: Data) {
        let str = String(data: data, encoding: .utf8) ?? ""
        
        if Utils.numberOfMatches(str, regex: "<b>시스템 메세지입니다</b>") > 0 {
            let alert = UIAlertController(title: "글 삭제 오류", message: "글을 삭제할 수 없습니다. 잠시후 다시 해보세요.", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default) { (action) in }
            alert.addAction(confirm)
            DispatchQueue.main.sync {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        DispatchQueue.main.sync {
            self.delegate?.articleView(self, didDelete: selectedRow)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func deleteCommentFinish(_ httpSessionRequest: HttpSessionRequest, _ data: Data) {
    }
    
    func deleteCommentConfirm(_ item: CommentItem) {
        
    }
    
    func WriteReComment(_ item: CommentItem) {
        
    }
    
    func copyComment(_ item: CommentItem) {
        
    }
    
    func shareComment(_ item: CommentItem) {
        
    }
}
