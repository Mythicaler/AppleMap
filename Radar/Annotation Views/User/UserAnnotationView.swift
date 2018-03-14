//
//  UserAnnotationView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 2/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//
import UIKit
import MapKit


protocol AnnotationViewDelegate {
    func didTouchStatusView(_ statusType: StatusType, userID: String, body: String?)
    func showUpdateStatus()
}

class UserAnnotationView: MKAnnotationView, UserStatusViewDelegate {
    // Delegate for touch event
    var delegate: AnnotationViewDelegate?
    
    private var profileImg: UIImage?
    private let pinBgImg = UIImage(named: "Radar_RedPinBg")!
    private let offset: CGFloat = 12 // Top y-offset between the profile image and the pin background.
    private var statusText: String?
    private var timestamp: Double?
    private var statusType: StatusType!
    
    // Status (callout).
    private var statusView: UserStatusView?
    
    // Display name
    var displayName: String?
    
    // Status dictionary
    var statusDictionary: Dictionary<String, Any>? {
        didSet {
            var newStatusType: StatusType

            if statusDictionary == nil {
                newStatusType = .NoStatus
            } else {
                // Get user value
                switch (statusDictionary!["statusType"] as! String) {
                case "TEXT_ONLY":
                    newStatusType = .TextOnly
                case "IMAGE_ONLY":
                    newStatusType = .ImageOnly
                case "TEXT_AND_IMAGE":
                    newStatusType = .ImageAndText
                default:
                    newStatusType = .NoStatus
                }
            }
            
            var statusTypeChanged = false
            
            if newStatusType != statusType {
                statusTypeChanged = true
            }
            
            statusType = newStatusType
            
            self.statusText = statusDictionary?["body"] as? String
            
            self.timestamp = (statusDictionary?["updated"] as? Dictionary<String, Any>)?["timestamp"] as? Double
            
            if (statusType == .ImageOnly || statusType == .ImageAndText) {
                // pre-load image in background
                let imageView = UIImageView()
                let imageRef = Storage.storage().reference(forURL: "gs://miss-chief.appspot.com/profiles/" + Auth.auth().currentUser!.uid + "/status.jpg")
                SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
                imageView.sd_setImage(with: imageRef)
            } else if (statusType == .NoStatus) {
                self.statusText = "No status update yet"
                self.timestamp = nil
            }
            
            // set status only when status view is already created
            if self.statusView != nil {
                var wasStatusHidden = true
                if self.statusView!.isHidden == false {
                    wasStatusHidden = false
                }
                
                // If type is changed, need to recreate status view
                if statusTypeChanged {
                    self.statusView?.removeFromSuperview()
                    self.statusView = nil
                }
                
                // If status was not hidden, need to update current status view
                if wasStatusHidden == false {
                    self.showStatus()
                }
            }
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        // TODO
        // Listen to profile image path change, download the new image, and call set needs display.
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        // Add listener for profile change
        let nc = NotificationCenter.default
//        nc.addObserver(forName:Notification.Name(rawValue:"ProfileChanged"),
//                       object:nil, queue:nil) {
//                        notification in
//                        self.loadProfileImage()
//        }
        
        self.loadProfileImage()
        
        // Set view size.
        self.bounds = CGRect(
            x: 0, y: 0,
            width: pinBgImg.size.width,
            height: pinBgImg.size.height
        )
        
        // Set clear background.
        self.backgroundColor = UIColor.clear
    }
    
    func loadProfileImage() {
        // Read profile image from Firebase.
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let imageRef = storage.reference(forURL: "gs://miss-chief.appspot.com/profiles/" + Auth.auth().currentUser!.uid + "/pinProfilePhoto.jpg")
        
        let profileImageView = UIImageView()
        SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
        profileImageView.sd_setImage(with: imageRef, placeholderImage: nil) { (image, error, _, _) in
            if image != nil {
                // get your image
                let image: UIImage = image!.resizedImage(byMagick: "\(Int(45 * UIScreen.main.scale))x\(Int(45 * UIScreen.main.scale))!")
                // begin a new image
                let bounds = CGRect(x: 0, y: 0, width: 45, height: 45)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 45, height: 45), false, UIScreen.main.scale)
                // add a clip in the shape of a rounded rectangle
                UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.width / 2).addClip()
                // draw the image in the view
                image.draw(in: bounds)
                self.profileImg = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self.setNeedsDisplay()
            }
            else {
                var images = UIImage(named: "AddProfileImage")
                let image: UIImage = images!.resizedImage(byMagick: "\(Int(45 * UIScreen.main.scale))x\(Int(45 * UIScreen.main.scale))!")
                // begin a new image
                let bounds = CGRect(x: 0, y: 0, width: 45, height: 45)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 45, height: 45), false, UIScreen.main.scale)
                // add a clip in the shape of a rounded rectangle
                UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.width / 2).addClip()
                // draw the image in the view
                image.draw(in: bounds)
                self.profileImg = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                self.setNeedsDisplay()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // No accompanying xib file.
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Draw user profile image on top of the pin background image.
        
        pinBgImg.draw(at: CGPoint(x: 0, y: 0))
        
        if let profileImg = profileImg {
            let xOffset: CGFloat = (pinBgImg.size.width/2) - (profileImg.size.width/2) // Center image.
            let yOffset: CGFloat = pinBgImg.size.height - profileImg.size.height - offset // Offset from top.
            
            profileImg.draw(at: CGPoint(x: xOffset, y: yOffset))
        }
    }
    
    // MARK: - Override hit test
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if statusView != nil && !statusView!.isHidden && (statusView!.frame as CGRect).contains(point) {
//            print("returned status view")
//            return statusView!.hitTest(point, with: event)
//        } else {
//            print("go up")
//            return super.hitTest(point, with: event)
//        }
//    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if statusView != nil && !statusView!.isHidden && (statusView!.frame as CGRect).contains(point) {
            return true
        } else {
            return super.point(inside: point, with: event)
        }
    }
    
    // MARK: - Action methods
    
    /**
     Create new status view. To be called when statusView is nil on the first access, or when the
     status type has changed.
     */
    private func createStatusView(type: StatusType) {
        
        var nibName = "UserTextOnlyStatusView"
        if type == StatusType.ImageOnly {
            nibName = "UserImageOnlyStatusView"
        } else if type == StatusType.ImageAndText {
            nibName = "UserImageAndTextStatusView"
        }
        
        let statusView = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?[0] as! UserStatusView
        statusView.delegate = self
        
        // Position.
        statusView.center = CGPoint(
            x: bounds.size.width/2,
            y: -statusView.frame.size.height/2 + bounds.height) // Cover the annotation view.
        
        // Add subview.
        addSubview(statusView)
        
        self.statusView = statusView
        self.statusView?.profileImageImgV.image = profileImg
    }
    
    /**
     Show status view.
     */
    func showStatus() {
        if statusView == nil {
            // (Re)create status view - shown by default.
            createStatusView(type: statusType!)
        } else {
            // Show status.
            self.statusView?.isHidden = false
        }
        
        setStatus()
    }
    
    /**
     Hide status view.
     */
    func hideStatus() {
        self.statusView?.isHidden = true
    }
    
    // set UI variables for status view
    func setStatus() {
        self.statusView!.displayName = displayName
        if (statusView is UserTextOnlyStatusView) {
            (self.statusView as! UserTextOnlyStatusView).statusText = statusText
        } else if (statusView is UserImageAndTextStatusView) {
            (self.statusView as! UserImageAndTextStatusView).statusText = statusText
        }
        
        if (statusView is UserImageAndTextStatusView) {
            (self.statusView as! UserImageAndTextStatusView).updateStatusImage()
        } else if (statusView is UserImageOnlyStatusView) {
            (self.statusView as! UserImageOnlyStatusView).updateStatusImage()
        }
        
        self.statusView?.timestamp = self.timestamp
    }
    
    // MARK: - UserStatusViewDelegate
    func didTouchView() {
        delegate?.didTouchStatusView(statusType, userID: Auth.auth().currentUser!.uid, body: statusText)
    }
    
    func showUpdateStatus() {
        delegate?.showUpdateStatus()
    }
}
