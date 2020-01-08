//
//  String+localized.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2020/01/08.
//  Copyright © 2020 Yusaku. All rights reserved.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}
