//
//  SetView.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/11.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import os.log

protocol SetViewDelegate {
    
}

class SetView : CommonView {

    //MARK: Properties

    @IBOutlet var title1Label : UILabel!
    @IBOutlet var title2Label : UILabel!
    @IBOutlet var title3Label : UILabel!

    @IBOutlet var idLabel : UILabel!
    @IBOutlet var pwLabel : UILabel!
    @IBOutlet var swLabel : UILabel!
    @IBOutlet var systemSyncLabel : UILabel!
    @IBOutlet var darkModeLable : UILabel!

    @IBOutlet var idField : UITextField!
    @IBOutlet var pwField : UITextField!
    @IBOutlet var swPush : UISwitch!
    @IBOutlet var systemSyncSwitch : UISwitch!
    @IBOutlet var darkModeSwich : UISwitch!

    override func viewDidLoad() {
        self.title = "설정"
        
        if #available(iOS 13.0, *) {
            title3Label.isHidden = false
            systemSyncLabel.isHidden = false
            darkModeLable.isHidden = false
            systemSyncSwitch.isHidden = false
            darkModeSwich.isHidden = false
        } else {
            title3Label.isHidden = true
            systemSyncLabel.isHidden = true
            darkModeLable.isHidden = true
            systemSyncSwitch.isHidden = true
            darkModeSwich.isHidden = true
        }
        
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        let bodyBoldFont = UIFont.preferredFont(forTextStyle: .body).bold()
        
        title1Label.font = bodyBoldFont
        title2Label.font = bodyBoldFont
        title3Label.font = bodyBoldFont
        idLabel.font = bodyFont
        pwLabel.font = bodyFont
        swLabel.font = bodyFont
        systemSyncLabel.font = bodyFont
        darkModeLable.font = bodyFont

        idField.font = bodyFont
        pwField.font = bodyFont
        
        let defaults = UserDefaults.standard
        
        idField.text = defaults.object(forKey: "userId") as? String
        pwField.text = defaults.object(forKey: "userPw") as? String
        swPush.setOn(defaults.bool(forKey: "push"), animated: true);
        systemSyncSwitch.setOn(defaults.bool(forKey: "systemSync"), animated: true);
        darkModeSwich.setOn(defaults.bool(forKey: "darkMode"), animated: true);

        darkModeSwich.isEnabled = !systemSyncSwitch.isOn
        
        super.viewDidLoad()
    }
    
    @objc override func contentSizeCategoryDidChangeNotification() {
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        let bodyBoldFont = UIFont.preferredFont(forTextStyle: .body).bold()
        
        title1Label.font = bodyBoldFont
        title2Label.font = bodyBoldFont
        title3Label.font = bodyBoldFont
        idLabel.font = bodyFont
        pwLabel.font = bodyFont
        swLabel.font = bodyFont
        systemSyncLabel.font = bodyFont
        darkModeLable.font = bodyFont

        idField.font = bodyFont
        pwField.font = bodyFont
    }
    
    // MARK: - LoginToServiceDelegate
    
    override func loginToService(_ loginToService: LoginToService, loginWithSuccess result: String) {
        print("login success")
        let loginToService = LoginToService()
        loginToService.delegate = self
        loginToService.PushRegister()
    }
    
    override func loginToService(_ loginToService: LoginToService, loginWithFail result: String) {
        print("login fail")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "로그인 오류", message: "아이디 혹은 비밀번호를 다시 확인하세요.", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default) { (action) in }
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func loginToService(_ loginToService: LoginToService, logoutWithSuccess result: String) {
        print("logout success")
        let loginToService = LoginToService()
        loginToService.delegate = self
        loginToService.Login()
    }
    
    override func loginToService(_ loginToService: LoginToService, logoutWithFail result: String) {
        print("logout fail")
        let loginToService = LoginToService()
        loginToService.delegate = self
        loginToService.Login()
    }
    
    override func loginToService(_ loginToService: LoginToService, pushWithSuccess result: String) {
        print("push success")
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func loginToService(_ loginToService: LoginToService, pushWithFail result: String) {
        print("push fail")
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - User Functions
    
    func showAlert() {
        let alert = UIAlertController(title: "로그인 오류", message: "아이디 혹은 비밀번호를 다시 확인하세요.", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { (action) in }
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender: UIBarButtonItem) {
        if idField.text == "" || pwField.text == "" {
            showAlert()
            return
        }
        
        let defaults = UserDefaults.standard
        
        defaults.set(idField.text ?? "", forKey: "userId")
        defaults.set(pwField.text ?? "", forKey: "userPw")
        defaults.set(swPush.isOn, forKey: "push")
        defaults.set(systemSyncSwitch.isOn, forKey: "systemSync")
        defaults.set(darkModeSwich.isOn, forKey: "darkMode")
        
        let loginToService = LoginToService()
        loginToService.delegate = self
        loginToService.Logout()
    }
    
    @IBAction func actionSystemSync(_ sender: UISwitch) {
        darkModeSwich.isEnabled = !sender.isOn
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "systemSync")
        if #available(iOS 13.0, *) {
            if sender.isOn {
                overrideUserInterfaceStyle = .unspecified
            } else {
                if defaults.bool(forKey: "darkMode") {
                    overrideUserInterfaceStyle = .dark
                } else {
                    overrideUserInterfaceStyle = .light
                }
            }
        }
    }

    @IBAction func actionDarkMode(_ sender: UISwitch) {
        if #available(iOS 13.0, *) {
            if sender.isOn {
                overrideUserInterfaceStyle = .dark
            } else {
                overrideUserInterfaceStyle = .light
            }
            
        }
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "darkMode")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for (_, value) in appDelegate.commonViews{
            let commonView = value as? CommonView
            commonView?.refreshWindow()
        }
    }
}
