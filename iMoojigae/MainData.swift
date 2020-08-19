//
//  MainData.swift
//  iMooojigae
//
//  Created by dykim on 2020/06/27.
//  Copyright © 2020 dykim. All rights reserved.
//

import UIKit
import os.log

class MainData {
    
    //MARK: Properties
    var name: String
    
    init?(name: String) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
    }
}
