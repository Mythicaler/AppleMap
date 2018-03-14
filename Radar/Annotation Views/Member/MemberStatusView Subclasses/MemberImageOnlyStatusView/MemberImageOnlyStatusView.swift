//
//  MemberImageOnlyStatusView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 1/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class MemberImageOnlyStatusView: MemberStatusView {
  
  @IBOutlet weak var statusImageImgV: UIImageView!
  
  // MARK: - Computed properties
  
  // Update status image.
  func updateStatusImage() {
    if memberId == nil {
      return
    }
    
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    // Create a storage reference from our storage service
    let imageRef = storage.reference(forURL: "gs://miss-chief.appspot.com/profiles/" + memberId! + "/status.jpg")
    SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
    statusImageImgV.sd_setImage(with: imageRef)
  }
}
