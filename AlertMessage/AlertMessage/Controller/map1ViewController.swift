//
//  map1ViewController.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/30/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class map1ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let storageRef = Storage.storage().reference()
    var imageMap = [String:UIImage?]()
    var imageReadyMap = [String:Bool]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var riskLevelSelector: UISlider!
    
    
    let locationManager: CLLocationManager = {
        let locaManager = CLLocationManager()
        locaManager.desiredAccuracy = kCLLocationAccuracyBest
        return locaManager
    }()
    var locationUpdateTimer: Timer?
    var listenerForAllUsers: ListenerRegistration?
    var userMap = [String:UserAnnotationInfo]()
    let db = Firestore.firestore()
    
    //MARK: VC life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        setUpMapView()
        setUpSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationUpdateTimer!.invalidate()
        listenerForAllUsers!.remove()
        
        locationUpdateTimer = nil
        listenerForAllUsers = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLocation()
        listenToCollectionFromDatabase()
    }
    
    func setUpMapView() {
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.center = view.center
    }
    
    func setUpSlider() {
        
        var initSliderValue: Float = riskLevelSelector.minimumValue
        switch User.status {
        case .normal:
            initSliderValue = riskLevelSelector.minimumValue
        case .risky:
            initSliderValue = riskLevelSelector.minimumValue + (riskLevelSelector.maximumValue - riskLevelSelector.minimumValue)/2
        case .emergent:
            initSliderValue = riskLevelSelector.maximumValue
        default:
            break
        }
        
        riskLevelSelector.setValue(initSliderValue, animated: true)
        riskLevelSelector.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        riskLevelSelector.isContinuous = false
    }
    
    @objc func sliderValueChanged(uislider: UISlider) {
        let value = uislider.value
        let range = uislider.maximumValue - uislider.minimumValue
        let valueAtNormal = uislider.minimumValue
        let valueAtRisk = uislider.minimumValue + 1/2 * range
        let valueAtEmergent = uislider.maximumValue
        
        if value < uislider.minimumValue + 1/3 * range {
            uislider.setValue(valueAtNormal, animated: true)
            User.status = .normal
        }
        else if value >= uislider.maximumValue - 1/3 * range {
            uislider.setValue(valueAtEmergent, animated: true)
            User.status = .emergent
        }
        else {
            uislider.setValue(valueAtRisk, animated: true)
            User.status = .risky
        }
        
        
        
        let docData: [String:String] = [
            K.FStore.statusField: User.status.description()
        ]
        
       db.collection(K.FStore.collectionName).document(User.email!).updateData(docData) { err in
           if let err = err {
               print ("[Error][map1ViewController] fail to update status info: \(err)")
           }
           else {
               print("[Success][map1ViewController] succeed to update status info")
           }
       }
        
    }
    //MARK: Location and Map utilities
    
    func updateLocation() {
        //self.locationManager.startUpdatingLocation() //update event is generated only if movement exceeds minimum distance defined by distanceFilter
        
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: Config.updateTimeInterval, repeats: true) {
            (timer) in
            self.locationManager.requestLocation()
        }
        
    }


    func listenToCollectionFromDatabase() {
        
        listenerForAllUsers = self.db.collection(K.FStore.collectionName).addSnapshotListener { (documentSnapshot, error) in
            if let err = error {
                print("Error: \(err)")
            }
            else {
                if let snapshotDocuments = documentSnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let email = doc.documentID
                        if let status = data[K.FStore.statusField] as? String,
                            let lat = data[K.FStore.latField] as? Double,
                            let lon = data[K.FStore.lonField] as? Double,
                            let username = data[K.FStore.usernameField] as? String
                        {
                            print("fetch----------\(username)------------")
                            if (username == User.username!) {
                                self.setRegionCenteringUser(lat: lat, lon: lon)
                            }
                            
                            let userAnnotationInfo = UserAnnotationInfo(status: status, lon: lon, lat: lat, email: email)
                            self.userMap[username] = userAnnotationInfo
                            if let ready = self.imageReadyMap[username] {
                            }
                            else {
                                self.downloadOtherPhoto(name: username)
                            }
                        }
                    }
                    self.updateMap()
                }
                
            }
        }
    }
    
    func downloadOtherPhoto(name: String) {
        let imageRef = storageRef.child("\(name)/image.jpg")
        imageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error {
                print("[Error][loginViewController] download image: \(error)")
                self.imageMap[name] = UIImage(named: "userImagePlaceholder")
            }
            else {
                self.imageMap[name] = UIImage(data: data!)
                self.imageReadyMap[name] = true
            }

        }
    }
    
    func setRegionCenteringUser(lat: Double, lon: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: Config.geoFence, longitudeDelta: Config.geoFence)
        let region = MKCoordinateRegion(center: coord, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    var polylineArray: [MKPolyline] = []
    var annotationArray: [CustomAnnotation] = []
    func updateMap() {
        
       
        mapView.removeOverlays(polylineArray)
        polylineArray.removeAll()
        mapView.removeAnnotations(annotationArray)
        annotationArray.removeAll()
        
        //Add annotations
        for (username, info) in userMap {
            print("annotation--------\(username)--------")
            
            if info.status == "offline" {
                Utility.sendEmailToFriend(victim: User.username!,
                                          victimEmail: User.email!,
                                          friend: username,
                                          friendEmail: info.email)
            }
            else {                
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2D(latitude: info.lat, longitude: info.lon)
//                annotation.title = username
//                annotation.subtitle = info.status
                let annotation = self.addCustomAnnotation(lat: info.lat, lon: info.lon, username: username, status: info.status)
                annotationArray.append(annotation)
            }
        }
        mapView.addAnnotations(annotationArray)
        
        //Add polylines via overlays
        guard let startlat = userMap[User.username!]?.lat,
            let startlon = userMap[User.username!]?.lon else {
                return
        }
        
        var lineCoords:[CLLocationCoordinate2D] = []
        let startCoord = CLLocationCoordinate2D(latitude: startlat, longitude: startlon)
        //case 1: I am victim - victim to all surrounding non-emergent users
        if (userMap[User.username!]?.status == "risky" || userMap[User.username!]?.status == "emergent" ) {
            for annotation in annotationArray {
                if User.username != annotation.title && annotation.subtitle != "emergent" {
                    let endCoord = annotation.coordinate
                    lineCoords = [startCoord, endCoord]
                    let line = MKPolyline(coordinates: lineCoords, count: lineCoords.count)
                    polylineArray.append(line)
                }
            }
            
        }
        //case 2: I am hero - I actively connect to surrounding victims
        else if (userMap[User.username!]?.status == "normal") {
            for annotation in annotationArray {
                if User.username != annotation.title && annotation.subtitle == "emergent" {
                    let endCoord = annotation.coordinate
                    lineCoords = [startCoord, endCoord]
                    let line = MKPolyline(coordinates: lineCoords, count: lineCoords.count)
                    polylineArray.append(line)
                }
            }
        }
        mapView.addOverlays(polylineArray)
    }
    
    // MARK: add customized annotation
    func addCustomAnnotation(lat: Double, lon: Double, username: String, status: String) -> CustomAnnotation{
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let title = username
        let subtitle = status
        let annotation = CustomAnnotation(title: title, subtitle: subtitle, coord: coord)
        return annotation
    }
    
    
  
    
    
    /*
    // MARK: - Navigation
/Users/myj/xcode/AlertMessage/team-jaguar/AlertMessage/AlertMessage/Controller/ViewController.swift
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}

//MARK: - CLLocationManagerDelegate

extension map1ViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
           let lat = location.coordinate.latitude
           let lon = location.coordinate.longitude
//           print("lat \(lat)")
//           print("lon \(lon)")

            
            
            let docData: [String:Double] = [
                K.FStore.latField: lat,
                K.FStore.lonField: lon,
            ]
         
            db.collection(K.FStore.collectionName).document(User.email!).updateData(docData) { err in
                if let err = err {
                    print ("[Error][map1ViewController] fail to update coord info: \(err)")
                }
                else {
                    print("[Success][map1ViewController] succeed to update coord info")
                }
            }
            
        }

    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[Error][map1ViewController] fail to update location")
    }
    
    
}

//MARK: - MKMapViewDelegate
extension map1ViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           if let line = overlay as? MKPolyline {
               let lineRenderer = MKPolylineRenderer(polyline: line)
               lineRenderer.strokeColor = .blue
               lineRenderer.lineWidth = 2.0
               return lineRenderer
           }
           fatalError("Unexpected overlay type")
    }
}

//custom annotation
extension map1ViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        print("d annotation: \(annotation.title)")
        print("annotation: \(annotation.title!!)")
        print(imageReadyMap[annotation.title!!])
        if let ready = imageReadyMap[annotation.title!!] {
            annotationView.image = setUserAnnotationView(userPhoto: imageMap[annotation.title!!]!)
        }
        else {
            annotationView.image = setUserAnnotationView(userPhoto: UIImage(named: "userImagePlaceholder"))
        }
        annotationView.canShowCallout = true
        return annotationView
    }
}


//MARK: set up user annotation view on MapView
func setUserAnnotationView(userPhoto: UIImage?) -> UIImage {
    
    // resize user photo
    let size = CGSize(width: 50, height: 50)
    UIGraphicsBeginImageContext(size)
    
    if let userPhoto = userPhoto {
        userPhoto.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    else {
        UIImage(named: "userImagePlaceholder")!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    let userAnnotationView =  UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return userAnnotationView
}
