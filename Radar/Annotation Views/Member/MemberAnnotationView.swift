//
//  MemberAnnotationView.swift
//  Miss Chief
//
//  Created by Kevin Ng on 2/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//
import UIKit
import MapKit

class MemberAnnotationView: MKAnnotationView, MemberStatusViewDelegate {
    // Delegate for touch event
    var delegate: AnnotationViewDelegate?
    var displayName: String?
    
    private var pinView: MemberPinView
    private var statusView: MemberStatusView?
    
    var radar: MKMapView
    
    private var statusText: String?
    private var timestamp: Double?
    private var statusType: StatusType!
    
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
                let imageRef = Storage.storage().reference(forURL: "gs://miss-chief.appspot.com/profiles/" + (annotation as! MemberAnnotation).memberId + "/pinProfilePhoto.jpg")
                SDImageCache.shared().removeImage(forKey: imageRef.fullPath)
                imageView.sd_setImage(with: imageRef, placeholderImage: nil) { (image, _, _, _) in
                    if image == nil {
                        imageView.image = UIImage(named: "AddProfileImage")
                    }
                }
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
    
    override var annotation: MKAnnotation? {
        didSet {
            if annotation is MemberAnnotation {
                pinView.setMemberId((annotation as! MemberAnnotation).memberId)
            }
        }
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, radar: MKMapView) {
        let memberId = (annotation as! MemberAnnotation).memberId
        pinView = MemberPinView(userId: memberId)
        self.radar = radar
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        addSubview(pinView)
        
        // Set view size.
        bounds = CGRect(
            x: 0, y: 0,
            width: pinView.frame.width,
            height: pinView.frame.height
        )
        
        // Set clear background.
        backgroundColor = UIColor.clear
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Perform hit test on self.
        // In the annotation view, a hit-testable UI element (e.g. button) will return itself. The
        // annotation view itself will not return. So, touching a button in the annotation view will
        // cause this method to super view to bring this annotation view to the front (preventing it
        // from being dismissed), and return the button so it may handle touch events.
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil) {
            // Bring self to front if hit test passes.
            superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Take part in hit testing - trigger the hitTest method when the user taps within the bounds
        // of this annotation view.
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside) {
            for view in self.subviews {
                isInside = view.frame.contains(point);
                if isInside {
                    break;
                }
            }
        }
        return isInside;
    }
    
    // MARK: - Helper methods
    
    private func updateStatusPosition() {
        
        // DIFFERENTIATE BETWEEN ROTATED/NON-ROTATED BG PIN; and show the status view correctly.
        
        // Radar center Y.
        let radarMidY = radar.bounds.size.height / 2
        
        // Convert pin coordinates in respect to radar's bounds.
        let pinFrame = radar.convert(pinView.frame, from: pinView.superview)
        let pinY = pinFrame.origin.y
        
        // Show on top or bottom?
        // Default: pin is below fold - show status above pin.
        let statusCenterY: CGFloat
        if pinY < radarMidY {
            // Pin is above fold - show status below pin.
            statusCenterY = statusView!.bounds.height/2 - bounds.height/2 + 26
        } else {
            // Pin is below fold - show status above pin.
            statusCenterY = -statusView!.bounds.height/2 + bounds.height/2 - 27
        }
        
        statusView!.center = CGPoint(x: 0, y: statusCenterY)
        
        // Get status view's frame in relation to the radar view.
        let statusFrame = radar.convert(statusView!.frame, from: statusView!.superview)
        
        // Status view's width/height.
        let statusWidth = statusFrame.size.width
        let statusHeight = statusFrame.size.height
        
        let marginToEdge: CGFloat = 15
        
        // Adjust Y position.
        let statusY = statusFrame.origin.y
        if statusY < 0 {
            // Status goes out of the top edge.
            let diffY = statusY
            let frame = statusView!.frame
            statusView!.frame = CGRect(
                x: frame.origin.x,
                y: frame.origin.y - diffY + marginToEdge,
                width: statusWidth,
                height: statusHeight
            )
        } else if (statusY + statusHeight) > radar.bounds.size.height {
            // Status goes out of the bottom edge.
            let diffY = (statusY + statusHeight) - radar.bounds.size.height
            let frame = statusView!.frame
            statusView!.frame = CGRect(
                x: frame.origin.x,
                y: frame.origin.y - diffY - marginToEdge,
                width: statusWidth,
                height: statusHeight
            )
        }
        
        // Adjust X position.
        let statusX = statusFrame.origin.x
        if statusX < 0 {
            // Status goes out of the left edge.
            let diffY = statusX
            let frame = statusView!.frame
            statusView!.frame = CGRect(
                x: frame.origin.x - diffY + marginToEdge,
                y: frame.origin.y,
                width: statusWidth,
                height: statusHeight
            )
        } else if (statusX + statusWidth) > radar.bounds.size.width {
            // Status goes out of the right edge.
            let diffX = (statusX + statusWidth) - radar.bounds.size.width
            let frame = statusView!.frame
            statusView!.frame = CGRect(
                x: frame.origin.x - diffX - marginToEdge,
                y: frame.origin.y,
                width: statusWidth,
                height: statusHeight
            )
        }
    }
    
    /**
     Create new status view. To be called when statusView is nil on the first access, or when the
     status type has changed.
     */
    private func createStatusView(type: StatusType) {
        
        var nibName = "MemberTextOnlyStatusView"
        if type == StatusType.ImageOnly {
            nibName = "MemberImageOnlyStatusView"
        } else if type == StatusType.ImageAndText {
            nibName = "MemberImageAndTextStatusView"
        }
        
        let statusView = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?[0] as! MemberStatusView
        statusView.delegate = self
        statusView.memberId = (self.annotation as! MemberAnnotation).memberId
        
        // Add status behind the pin view.
        insertSubview(statusView, belowSubview: pinView)
        
        self.statusView = statusView
        
        // Note: we need to update status position after we have assigned the new statusView to the
        // class property.
        updateStatusPosition()
    }
    
    // MARK: - Action methods
    
    /**
     Show status view.
     */
    func showStatus() {        
        if statusView == nil {
            // (Re)create status view - shown by default.
            createStatusView(type: statusType!)
        } else {
            // Show status.
            statusView?.isHidden = false
        }
        
        setStatus()
        
        pinView.selected = true
    }
    
    /**
     Hide status view.
     */
    func hideStatus() {
        self.statusView?.isHidden = true
        pinView.selected = false
    }
    
    // set UI variables for status view
    func setStatus() {
        if (statusView is MemberTextOnlyStatusView) {
            (self.statusView as! MemberTextOnlyStatusView).statusText = statusText
        } else if (statusView is MemberImageAndTextStatusView) {
            (self.statusView as! MemberImageAndTextStatusView).statusText = statusText
        }
        
        if (statusView is MemberImageAndTextStatusView || statusView is MemberImageOnlyStatusView) {
            (self.statusView as! MemberImageAndTextStatusView).updateStatusImage()
        } else if (statusView is MemberImageOnlyStatusView) {
            (self.statusView as! MemberImageOnlyStatusView).updateStatusImage()
        }
        self.statusView?.displayName = displayName
        self.statusView?.timestamp = self.timestamp
    }
    
    // MARK: - MemberStatusViewDelegate
    func didTouchView() {
        delegate?.didTouchStatusView(statusType, userID: (annotation as! MemberAnnotation).memberId, body: statusText)
    }
}


