//
//  MemberPinView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 3/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import UIKit
import SDWebImage

class MemberPinView: UIView {
  
  private var _selected = false
  var selected: Bool {
    get {
      return _selected
    }
    set {
      setNeedsDisplay()
      _selected = newValue
    }
  }
    
  
  private var profileImg: UIImage?
  private var pinBgImg = UIImage(named: "Radar_BluePinBg")! // Background for non-selected state.
  private var pinBgImgSel = UIImage(named: "Radar_BluePinBgSel")! // Background for selected state.
  private let offset: CGFloat = 8
  private var userId: String!
  
  init(userId: String) {
    super.init(frame: CGRect.zero)
    
    selected = _selected
    
    // Set view size.
    setSize()
    
    // Set clear background.
    backgroundColor = UIColor.clear
    
    setMemberId(userId)
  }
    
    func setMemberId(_ memberId: String) {
        userId = memberId
        
        // Read user profile image from Firebase.
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let imageRef = storage.reference(forURL: "gs://miss-chief.appspot.com/profiles/" + userId + "/pinProfilePhoto.jpg")
        
        let profileImageView = UIImageView()
        SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
        profileImageView.sd_setImage(with: imageRef, placeholderImage: nil) { (image, error, _, _) in
            var newImage: UIImage
            let imageSize: CGFloat = 35
            if image == nil {
                var tempImage = UIImage(named: "AddProfileImage")
                newImage = tempImage!.resizedImage(byMagick: "\(Int(imageSize * UIScreen.main.scale))x\(Int(imageSize * UIScreen.main.scale))!")
            }
            else {
                newImage = image!.resizedImage(byMagick: "\(Int(imageSize * UIScreen.main.scale))x\(Int(imageSize * UIScreen.main.scale))!")
            }
                // get your image
            
                // begin a new image
                let bounds = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize, height: imageSize), false, UIScreen.main.scale)
                // add a clip in the shape of a rounded rectangle
                UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.width / 2).addClip()
                // draw the image in the view
                newImage.draw(in: bounds)
                self.profileImg = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self.setNeedsDisplay()
        }
    }
  
  override init(frame: CGRect) {
    // TODO
    // Listen to profile image update from Firebase.
    
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    // Draw pin background backed on selected state.
    if selected {
      pinBgImgSel.draw(at: CGPoint(x: 0, y: 0))
    } else {
      pinBgImg.draw(at: CGPoint(x: 0, y: 0))
    }
    
    if let profileImg = profileImg {
      let xOffset: CGFloat = (pinBgImg.size.width/2) - (profileImg.size.width/2) // Center image.
      let yOffset: CGFloat = pinBgImg.size.height - profileImg.size.height - offset // Offset from top.
      
      // Draw user profile image on top of the pin background image.
      profileImg.draw(at: CGPoint(x: xOffset, y: yOffset))
    }
  }
  
  // MARK: - Helper methods
  
  private func setSize() {
    bounds = CGRect(
      x: 0, y: 0,
      width: pinBgImg.size.width,
      height: pinBgImg.size.height
    )
  }
  
  // MARK: - Action methods
  
  func rotateByDegrees(degrees: CGFloat) {
    pinBgImgSel = pinBgImgSel.imageRotatedByDegrees(degrees: degrees)
    pinBgImg = pinBgImg.imageRotatedByDegrees(degrees: degrees)
    setSize()
  }
}
