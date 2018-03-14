//
//  ViewController.swift
//  AppleMap
//
//  Created by Admin on 27/09/2017.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import MapKit
import LGButton
import CoreLocation
import Foundation

class NearMapViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    // MARK: Attributes
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet var radarMap: MKMapView!
    @IBOutlet var colView: UICollectionView!
    @IBOutlet var alphaView: LGButton!
    
    var regioinRadius: CLLocationDistance = CLLocationDistance(me.searchdistance * 1000)
    
    var pointAnnotation: CustomPointAnnotation!
    var pinAnnotationView: MKAnnotationView!
    var annotations = [MKAnnotation]()
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        radarMap.delegate = self
        radarMap.showsUserLocation = true
        self.colView.delegate = self
        self.colView.dataSource = self
        colView.isHidden = true
        alphaView.isHidden = true
        
        let fontattr = NSDictionary(object: UIFont(name: "Karla-Bold", size: 14.0)!, forKey: NSFontAttributeName as NSCopying)
        segment.setTitleTextAttributes(fontattr as [NSObject : AnyObject] , for: .normal)        
        
        if(cur_loc.latitude != 0.0 || cur_loc.longitude != 0.0) {
            let initialLocation = CLLocation(latitude: (cur_loc.latitude), longitude: (cur_loc.longitude))
            centerMapOnLocation(location: initialLocation)
        }
        
        colView.scrollIndicatorInsets = UIEdgeInsets.init(top: 78, left: 0, bottom: 0, right: 0)
        colView.contentInset = UIEdgeInsets.init(top: 78, left: 16, bottom: 0, right: 16)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    @IBAction func touchBtListview(_ sender: LGButton) {
        if(colView.isHidden){
            colView.isHidden = false
            alphaView.isHidden = false
            sender.titleString = "MAP VIEW"
        } else {
            colView.isHidden = true
            alphaView.isHidden = true
            sender.titleString = "LIST VIEW"
        }
    }
    @IBAction func touchNavMenu(_ sender: Any) {
        self.sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    @IBAction func touchNavMessage(_ sender: Any) {
        messageVC.is_menu = false
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    @IBAction func touchSegment(_ sender: Any) {
        self.sideMenuController?.rootViewController = discoverVC
        segment.selectedSegmentIndex = 1
    }
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return near_users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! CollectionViewCell
        let user = near_users[indexPath.row]
        
        let cview = UIImageView()
        if(user.gender == "Female") {
            cview.sd_setImage(with: user.avatar, placeholderImage: female_avatar_empty)
        } else {
            cview.sd_setImage(with: user.avatar, placeholderImage: male_avatar_empty)
        }
        cview.contentMode = .scaleAspectFill
        let size = (cell.frame.width) * 72 / 96
        cview.frame = CGRect(x: cell.bounds.midX - size / 2, y: 6, width: size, height: size)
        cview.layer.cornerRadius = size / 2
        cview.clipsToBounds = true
        
        let lab = UILabel(frame: CGRect(x: cell.bounds.midX - size / 2, y: size + 13, width: size, height: 16))
        lab.textAlignment = .center
        lab.text = String.init(format: "%@, %d", user.name, User.getAge(birthday: user.birthday))
        lab.font = UIFont(name: "Karla-Regular", size: 12.0)
        lab.textColor = UIColor.white
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        cell.addSubview(cview)
        cell.addSubview(lab)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Discover", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewNearbyProfileViewController") as! ViewNearbyProfileViewController
        controller.user_id = indexPath.row
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 86) / 3
        let height = width * 112 / 96
        let size = CGSize(width: width, height: height)
        return size
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    // MARK: Add Annotation Map
    func addAnnotation(id: Int, user: User, coordinate: CLLocationCoordinate2D)
    {
//        if user.invisiblemode == true {
//            return
//        }
        
        pointAnnotation = CustomPointAnnotation()
        pointAnnotation.id = id
        pointAnnotation.user = user
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = "Nearby User"
        
        radarMap.addAnnotation(pointAnnotation)
        annotations.append(pointAnnotation)
    }
    
    func showNearbyUsers() {
        radarMap.removeAnnotations(annotations)
        annotations.removeAll()
        if(cur_loc.latitude != 0.0 || cur_loc.longitude != 0.0) {
            for (index, user) in near_users.enumerated() {
                print("user locations = \(String(describing: user.latitude)) \(String(describing: user.longitude))")
                addAnnotation(id: index, user: user, coordinate: CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude))
            }
            DispatchQueue.main.async {
                self.colView.reloadData()
            }
        }
    }
    
    
    // MARK: Map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if(annotation.isKind(of: MKUserLocation.classForCoder())){
            //            return MKAnnotationView(annotation: annotation, reuseIdentifier: "userlocation")
//            radarMap.setRegion(MKCoordinateRegionMakeWithDistance(annotation.coordinate, regioinRadius*2, regioinRadius * 2), animated: true)
//            annotationView?.image = UIImage(named: "center")
            return nil
        }
        
        for view in (annotationView?.subviews)! {
            view.removeFromSuperview()
        }
        let customPointAnnotation = annotation as! CustomPointAnnotation
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        if(customPointAnnotation.user.gender == "Female") {
            imageView.sd_setImage(with: customPointAnnotation.user.avatar, placeholderImage: female_avatar_empty)
        } else {
            imageView.sd_setImage(with: customPointAnnotation.user.avatar, placeholderImage: male_avatar_empty)
        }
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.layer.borderColor = UIColor.beige.cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        
        annotationView?.addSubview(imageView)
        
        let center = annotationView?.center
        annotationView?.frame = imageView.frame
        annotationView?.center = center!
        annotationView?.tag = customPointAnnotation.id
        
        annotationView?.dropShadow()
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        if(view.annotation?.isKind(of: MKUserLocation.classForCoder()))! {
            return
        }
        
        let storyboard = UIStoryboard(name: "Discover", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewNearbyProfileViewController") as! ViewNearbyProfileViewController
        controller.user_id = view.tag
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regioinRadius * 2.0, regioinRadius * 2.0)
        
        radarMap.setRegion(coordinateRegion, animated: true)
    }
}

