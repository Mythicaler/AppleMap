//
//  UserImageOnlyStatusView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 31/1/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit


class UserImageOnlyStatusView: UserStatusView {

  @IBOutlet weak var statusImageImgV: UIImageView!
  
  // MARK: - Computed properties
  
  // Update status image.
  func updateStatusImage() {
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    // Create a storage reference from our storage service
    let imageRef = storage.reference(forURL: "gs://miss-chief.appspot.com/profiles/" + Auth.auth().currentUser!.uid + "/status.jpg")
    SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
    statusImageImgV.sd_setImage(with: imageRef)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
}
