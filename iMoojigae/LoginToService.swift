//
//  LoginToService.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/11.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit

protocol LoginToServiceDelegate: AnyObject {
    func loginToService(_ loginToService: LoginToService, loginWithSuccess result: String)
    func loginToService(_ loginToService: LoginToService, loginWithFail result: String)
    func loginToService(_ loginToService: LoginToService, logoutWithSuccess result: String)
    func loginToService(_ loginToService: LoginToService, logoutWithFail result: String)
    func loginToService(_ loginToService: LoginToService, pushWithSuccess result: String)
    func loginToService(_ loginToService: LoginToService, pushWithFail result: String)
}

class LoginToService: NSObject, HttpSessionRequestDelegate {
    var delegate: LoginToServiceDelegate?
    var userId : String = ""
    var userPwd : String = ""
    var swPush : NSNumber = 1
    
    func Login() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fullPath = paths[0].appendingPathComponent("set.dat")
        do {
            let fileData = try Data(contentsOf: fullPath)
            let setStorage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! SetStorage
            userId = setStorage.userId
            userPwd = setStorage.userPwd
            swPush = setStorage.swPush
        } catch {
            print("Couldn't read set.dat file")
        }
        
        let paramString = "userId=" + userId + "&userPw=" + userPwd + "&boardId=&boardNo=&page=1&categoryId=-1&returnURI=&returnBoardNo=&beforeCommand=&command=LOGIN"

        let urlResource = GlobalConst.ServerName + "/login-process.do"
        let referer = GlobalConst.ServerName + "/MLogin.do"
        
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.LOGIN_TO_SERVER
        httpSessionRequest.requestWithParamString(httpMethod: "POST", resource: urlResource, paramString: paramString, referer: referer)
    }
    
    func Logout() {
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.LOGOUT_TO_SERVER
        httpSessionRequest.requestWithParamString(httpMethod: "GET", resource: GlobalConst.ServerName + "/logout.do", paramString: "", referer: "")
    }

    func PushRegister() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fullPath = paths[0].appendingPathComponent("token.dat")
        var token = ""
        do {
            let fileData = try Data(contentsOf: fullPath)
            let setTokenStorage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! SetTokenStorage
            token = setTokenStorage.token
        } catch {
            print("Couldn't read token.dat file")
        }
        
        if token == "" {
            self.delegate?.loginToService(self, pushWithFail: "")
            return
        }
        
        if GlobalConst.userId == "" {
            self.delegate?.loginToService(self, pushWithFail: "")
            return
        }
        
        var pushYN = "Y"
        if GlobalConst.swPush == 0 {
            pushYN = "N"
        }
        let jsonObject = ["type": "iOS", "push_yn": pushYN, "uuid": token, "userid": GlobalConst.userId]
        
        let httpSessionRequest = HttpSessionRequest()
        httpSessionRequest.delegate = self
        httpSessionRequest.tag = GlobalConst.PUSH_REGISTER
        httpSessionRequest.requestWithJson(httpMethod: "POST", resource: GlobalConst.ServerName + "/push/PushRegister", json: jsonObject, referer: "")
    }
    
    //MARK: - HttpSessionRequestDelegate
    
    func httpSessionRequest(_ httpSessionRequest:HttpSessionRequest, didFinishLodingData data: Data) {
        if httpSessionRequest.tag == GlobalConst.LOGIN_TO_SERVER {
            let returnString = String(decoding: data, as: UTF8.self)
            print (returnString)
            if returnString.contains("<script language=javascript>moveTop()</script>") {
                GlobalConst.userId = userId
                GlobalConst.swPush = 1
                self.delegate?.loginToService(self, loginWithSuccess: "")
            } else {
                if returnString.contains("<b>시스템 메세지입니다</b>") {
                    self.delegate?.loginToService(self, loginWithFail: "")
                } else {
                    GlobalConst.userId = userId
                    GlobalConst.swPush = 1
                    self.delegate?.loginToService(self, loginWithSuccess: "")
                }
            }
        } else if httpSessionRequest.tag == GlobalConst.LOGOUT_TO_SERVER {
            self.delegate?.loginToService(self, logoutWithSuccess: "")
        } else {
            self.delegate?.loginToService(self, pushWithSuccess: "")
        }
    }
    
    func httpSessionRequest(_ httpSessionRequest: HttpSessionRequest, withError error: Error) {
        if httpSessionRequest.tag == GlobalConst.LOGIN_TO_SERVER {
            self.delegate?.loginToService(self, loginWithFail: "")
        } else if httpSessionRequest.tag == GlobalConst.LOGOUT_TO_SERVER {
            self.delegate?.loginToService(self, logoutWithFail: "")
        } else {
            self.delegate?.loginToService(self, pushWithFail: "")
        }
    }
 
    //MARK: - User Functions
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
