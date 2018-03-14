//
//  UserTextOnlyStatusView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 31/1/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit

class UserTextOnlyStatusView: UserStatusView {
  
  @IBOutlet weak var statusTextLbl: UILabel!
  
  // MARK: - Computed properties
  
  // Status text.
  private var _statusText: String?
  var statusText: String? {
    get {
      if _statusText == nil {
        return ""
      }
      
      return _statusText!
    }
    set {
      _statusText = newValue
      statusTextLbl.text = newValue
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
}
