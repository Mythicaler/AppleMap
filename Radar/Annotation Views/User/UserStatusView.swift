//
//  UserStatusView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 1/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit

protocol UserStatusViewDelegate {
    func didTouchView()
    func showUpdateStatus()
}

class UserStatusView: UIView {
    
    // Delegate for touch event
    var delegate: UserStatusViewDelegate?
    
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var profileImageImgV: UIImageView!
    
    // MARK: - Computed properties
    
    // Display name.
    private var _displayName: String?
    var displayName: String? {
        get {
            if _displayName == nil {
                return ""
            }
            
            return _displayName!
        }
        set {
            _displayName = newValue
            
            // Display display name.
            displayNameLbl.text = newValue
            displayNameLbl.sizeToFit()
        }
    }
    
    @IBAction func updateStatus(_ sender: Any) {
        delegate?.showUpdateStatus()
    }
    
    // Timestamp.
    private var _timestamp: Double?
    var timestamp: Double? {
        get {
            if _timestamp == nil {
                return -1
            }
            
            return _timestamp!
        }
        set {
            if newValue != nil {
                // Format timestamp for display.
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                //        formatter.timeZone = TimeZone(secondsFromGMT: 8*60*60) // TODO: track user timezone.
                
                // Display timestamp.
                timestampLbl.text = formatter.string(from: Date(timeIntervalSince1970: newValue!))
            } else {
                timestampLbl.text = ""
            }
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouchView()
    }
}
