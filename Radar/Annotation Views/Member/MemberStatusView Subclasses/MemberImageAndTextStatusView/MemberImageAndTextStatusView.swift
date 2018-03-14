//
//  MemberImageAndTextStatusView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 1/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class MemberImageAndTextStatusView: MemberStatusView {
  
  @IBOutlet weak var statusTextLbl: UILabel!
  @IBOutlet weak var statusImageImgV: UIImageView!
  
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
  
  // Update status image.
  func updateStatusImage() {
    if memberId == nil {
      return
    }
    
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    // Create a storage reference from our storage service
    let imageRef = Storage.storage().reference(forURL: "gs://miss-chief.appspot.com/profiles/" + memberId! + "/pinProfilePhoto.jpg")
    SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
    statusImageImgV.sd_setImage(with: imageRef, placeholderImage: nil) { (image, _, _, _) in
        if image == nil {
            self.statusImageImgV.image = UIImage(named: "AddProfileImage")
        }
    }
    
  }
}
