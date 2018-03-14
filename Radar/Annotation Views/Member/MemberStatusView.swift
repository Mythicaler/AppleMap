//
//  MemberStatusView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 1/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit
//import FirebaseDatabase
//import FirebaseAuth

protocol MemberStatusViewDelegate {
    func didTouchView()
}

class MemberStatusView: UIView {
    // Delegate for touch event
    var delegate: MemberStatusViewDelegate?
    
    var memberId: String?
    
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouchView()
    }
    
    // MARK: - Action methods
    
    @IBAction func nudgeButtonTapped(_ sender: Any) {
        if memberId != nil {
            // Nudge member.
//            print("Nudged \(self.memberId!)!")
           // Queue Error Occurred
            let uid = Auth.auth().currentUser!.uid
            // Write to queue
            let value: [String: Any] = [
                "uid": uid,
                "uidToNudge": self.memberId!,
                "time": Date().timeIntervalSince1970 as Double
            ]
            
            Database.database().reference().child("queues/nudge/tasks/\(uid)").setValue(value)
        }
    }
    
}
