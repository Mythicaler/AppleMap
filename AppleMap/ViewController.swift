//
//  ViewController.swift
//  AppleMap
//
//  Created by Admin on 27/09/2017.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet var radarMap: MKMapView!
    @IBOutlet var BtnListView: UIButton!
    @IBOutlet var colView: UICollectionView!
    @IBOutlet var alphaView: UIView!
    var imgname: [String] = []
    
    let locationManager = CLLocationManager()
    public var locValue: CLLocationCoordinate2D!
    let regioinRadius: CLLocationDistance = 200000
    
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKAnnotationView!
    
    @IBAction func onListView(_ sender: UIButton) {
        if(colView.isHidden)
        {
            colView.isHidden = false
            alphaView.isHidden = false
            BtnListView.setTitle("Map view", for: .normal)
        } else {
            colView.isHidden = true
            alphaView.isHidden = true
            BtnListView.setTitle("List view", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // MARK: add navigation items
        
        
        setButtons()
        
        imgname = ["img1","img2", "img3", "img4", "img5", "img6", "img7", "img8", "img9", "img10", "img11", "img12", "img13", "img14", "img15","img1","img2", "img3", "img4", "img5", "img6", "img7", "img8", "img9", "img10", "img11", "img12", "img13", "img14", "img15"]
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let gradient = CAGradientLayer()
        
        gradient.frame = alphaView.bounds
        gradient.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor, UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        alphaView.layer.insertSublayer(gradient, at: 0)
        
        radarMap.delegate = self
        radarMap.showsUserLocation = true
        
        let initialLocation = CLLocation(latitude: 37.785834, longitude: -122.406417)
        centerMapOnLocation(location: initialLocation)
        
        
        addAnnotation(image: "img3", coordinate: CLLocationCoordinate2D(latitude: 37.787845, longitude: -122.405328))
        addAnnotation(image: "img5", coordinate: CLLocationCoordinate2D(latitude: 37.783845, longitude: -122.406328))
        
        self.colView.delegate = self
        self.colView.dataSource = self
        colView.isHidden = true
        alphaView.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgname.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! CollectionViewCell

        
        let cview = UIImageView(image: UIImage(named: imgname[indexPath.row]))
        cview.contentMode = .scaleAspectFill
        let size = (cell.frame.width) * 72 / 96

        cview.frame = CGRect(x: cell.bounds.midX - size / 2, y: 6, width: size, height: size)
        

        cview.layer.cornerRadius = size / 2
        cview.clipsToBounds = true
        cell.addSubview(cview)
        
        let lab = UILabel(frame: CGRect(x: cell.bounds.midX - size / 2, y: size + 13, width: size, height: 16))
        lab.textAlignment = .center
        lab.text = "adf 30"
        
        cell.addSubview(lab)
        return cell
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
    
    func addAnnotation(image: String, coordinate: CLLocationCoordinate2D)
    {
        pointAnnotation = CustomPointAnnotation()
        pointAnnotation.imageName = image
        pointAnnotation.coordinate = coordinate
        
        pinAnnotationView = MKAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        radarMap.addAnnotation(pinAnnotationView.annotation!)
    }
    
    func setButtons()
    {
        let btnl = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        btnl.setBackgroundImage(UIImage(named: "leftBtnImg"), for: .normal)
        btnl.addTarget(self, action: #selector(ViewController.onTouchMenuButton), for: .touchUpInside)
        let leftButtonItem = UIBarButtonItem(customView: btnl)
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        let btnr = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        btnr.setBackgroundImage(UIImage(named: "rightBtnImg"), for: .normal)
        btnr.addTarget(self, action: #selector(ViewController.onTouchMessageButton), for: .touchUpInside)
        let rightButtonItem = UIBarButtonItem(customView: btnr)
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        
        let btnNearby = UIButton(frame: CGRect(x: 0, y: 0, width: 114, height: 32))
        btnNearby.setTitle("Nearby", for: .normal)
        btnNearby.addTarget(self, action: #selector(ViewController.onTouchNearby), for: .touchUpInside)
        btnNearby.backgroundColor = UIColor(colorLiteralRed: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1)
        btnNearby.isSelected = true
        btnNearby.isEnabled = false
        //       btnNearby.layer.cornerRadius = 4
        let maskPath1 = UIBezierPath(roundedRect: btnNearby.bounds,
                                     byRoundingCorners: [ .topRight, .bottomRight],
                                     cornerRadii: CGSize(width: 4, height: 4))
        
        let maskLayer1 = CAShapeLayer()
        maskLayer1.path = maskPath1.cgPath
        btnNearby.layer.mask = maskLayer1
        
        
        
        let btnDiscover = UIButton(frame: CGRect(x: 114, y: 0, width: 113, height: 32))
        btnDiscover.setTitle("Discover", for: .normal)
        btnDiscover.setTitleColor(UIColor(colorLiteralRed: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1), for: .normal)
        btnDiscover.addTarget(self, action: #selector(ViewController.onTouchDiscover), for: .touchUpInside)
        //        btnDiscover.layer.cornerRadius = 4
        
        let maskPath = UIBezierPath(roundedRect: btnDiscover.bounds,
                                    byRoundingCorners: [ .topLeft, .bottomLeft],
                                    cornerRadii: CGSize(width: 4, height: 4))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        btnDiscover.layer.mask = maskLayer
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 227, height: 32))
        titleView.addSubview(btnNearby)
        titleView.addSubview(btnDiscover)
        titleView.layer.cornerRadius = 4
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor = UIColor(red: 63/256.0, green: 214/256.0, blue: 181/256.0, alpha: 1).cgColor
        self.navigationItem.titleView = titleView
        
        let gradient = CAGradientLayer()
        
        gradient.frame = BtnListView.bounds
        gradient.colors = [UIColor(red: 42/256.0, green: 194/256.0, blue: 215/256.0, alpha: 1).cgColor, UIColor(red: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        BtnListView.layer.insertSublayer(gradient, at: 0)
        BtnListView.dropShadow()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = (manager.location?.coordinate)!
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
       
        
        let reuseIdentifier = "pin"
        var annotationView: MKAnnotationView
        let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if dequeuedView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.canShowCallout = true
        } else {
            dequeuedView?.annotation = annotation
            annotationView = dequeuedView!
        }
        
        if(annotation .isKind(of: MKUserLocation.classForCoder())){
            
            //            return MKAnnotationView(annotation: annotation, reuseIdentifier: "userlocation")
 //           radarMap.setRegion(MKCoordinateRegionMakeWithDistance(annotation.coordinate, regioinRadius*2, regioinRadius * 2), animated: true)
//            annotationView?.image = UIImage(named: "center")
            return nil
            
        }
        let customPointAnnotation = annotation as! CustomPointAnnotation
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        imageView.image = UIImage(named: customPointAnnotation.imageName)
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.layer.borderColor = UIColor(colorLiteralRed: 63/256.0, green: 214/256.0, blue: 181/256.0, alpha: 1).cgColor
        imageView.layer.borderWidth = 2
        imageView.clipsToBounds = true
        
        
//        annotationView?.image = UIImage(named: customPointAnnotation.imageName)
        annotationView.addSubview(imageView)
        annotationView.dropShadow()
        
        
        
        return annotationView
    }
    
    func onTouchMenuButton()
    {
        print("adfa")
    }
    func onTouchMessageButton()
    {
        print("fgjhjtj")
    }
    func onTouchNearby()
    {
        print("Nearby")
        let views = self.navigationItem.titleView?.subviews
        (views?[0] as! UIButton).isEnabled = false
        (views?[1] as! UIButton).isEnabled = true
        
        (views?[1] as! UIButton).backgroundColor = UIColor(colorLiteralRed: 256/256.0, green: 250/256.0, blue: 256/256.0, alpha: 1)
        (views?[1] as! UIButton).setTitleColor(UIColor(colorLiteralRed: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1), for: .normal)
        (views?[0] as! UIButton).backgroundColor = UIColor(colorLiteralRed: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1)
        (views?[0] as! UIButton).setTitleColor(UIColor.white, for: .normal)

    }
    func onTouchDiscover()
    {
        print("Discover")
        let views = self.navigationItem.titleView?.subviews
        

        (views?[1] as! UIButton).isEnabled = false
        (views?[0] as! UIButton).isEnabled = true

        (views?[0] as! UIButton).backgroundColor = UIColor(colorLiteralRed: 256/256.0, green: 250/256.0, blue: 256/256.0, alpha: 1)
        (views?[0] as! UIButton).setTitleColor(UIColor(colorLiteralRed: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1), for: .normal)
        (views?[1] as! UIButton).backgroundColor = UIColor(colorLiteralRed: 74/256.0, green: 212/256.0, blue: 181/256.0, alpha: 1)
        (views?[1] as! UIButton).setTitleColor(UIColor.white, for: .normal)
    }
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regioinRadius * 2.0, regioinRadius * 2.0)
        
        radarMap.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

