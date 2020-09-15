//
//  LinkView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/14.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import WebKit

class LinkView: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    //MARK: Properties
    
    @IBOutlet var webView : WKWebView!
    var linkName: String = ""
    var link: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = linkName
        
        guard let url = URL(string: "\(link)") else {
            print("URL is nil")
            return
        }
        let request = URLRequest(url: url)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.load(request)
    }
}
