//
//  AboutView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/23.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation
import UIKit

class AboutView : CommonView {
    
    //MARK: Properties

    @IBOutlet var textView : UITextView!
    
    override func viewDidLoad() {
        
        self.title = "앱정보"
        
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = bodyFont
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let msg = "무지개교육마을앱 for iOS\n버전 : \(version)\n개발자 : 호랑이\n문의메일 : panicstyle@gmail.com\n지원 페이지 : https://github.com/panicstyle/iMoojigae/wiki"
            textView.text = msg
        }
    }
    
    @objc override func contentSizeCategoryDidChangeNotification() {
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = bodyFont
    }
}
