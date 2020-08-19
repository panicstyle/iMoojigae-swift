//
//  NetworkHandler.swift
//  iMooojigae
//
//  Created by dykim on 2020/08/19.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation

protocol NetworkHandlerDelegate: AnyObject {
    func receiveData(_ data: Data)
}

class NetworkHandler {
    weak var delegate: NetworkHandlerDelegate?
    
    func getData(resource: String) {
        // 세션 생성, 환경설정
        let defaultSession = URLSession(configuration: .default)

        guard let url = URL(string: "\(resource)") else {
            print("URL is nil")
            return
        }

        // Request
        let request = URLRequest(url: url)

        // dataTask
        let dataTask = defaultSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // getting Data Error
            guard error == nil else {
                print("Error occur: \(String(describing: error))")
//                self.delegate?.receiveError(error)
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                self.delegate?.receiveError(error)
                return
            }
            self.delegate?.receiveData(data)
        }
        dataTask.resume()
    }
}
