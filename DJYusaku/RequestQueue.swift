//
//  RequestQueue.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/10/24.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import Foundation
import UIKit

class RequestQueue{
    private init(){}
    
    static let shared = RequestQueue()
    
    var music : [MusicDataModel] = []
}
