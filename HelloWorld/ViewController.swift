
// Created by Bojiang Li on 2/13/2022.
// Last commit by Bojiang Li on 3/21/2022.

import UIKit
import MapKit
import CoreLocation
///---MARK:
import AVFoundation
//import CoreLocationUI
//import AWSDynamoDB
//import ClientRuntime
//import AWSClientRuntime https://github.com/awslabs/aws-sdk-swift.git

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //audio config
    ///---MARK:
    var player:AVAudioPlayer? = nil
    lazy var musicButton:UIButton =  {
        let  musicButton = UIButton.init(frame: CGRect(x:0 ,y:0,width: 100  ,height: 40))
        musicButton.center = self.view.center
        musicButton.setTitle("PlayMusic", for: .normal)
        musicButton.backgroundColor = UIColor.black
        musicButton.addTarget(self, action: #selector(playMusic), for: .touchUpInside)
        return musicButton
    }()
    ///---MARK:
    var notification = false

    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
     
    fileprivate func createNotifyButton() {
        let button = UIButton(frame: CGRect(x: 140,
                                            y: 660,
                                            width: 200,
                                            height: 60))
        button.setTitle("Notification",
                        for: .normal)
        button.setTitleColor(.systemBlue,
                             for: .normal)
        
        button.addTarget(self,
                         action: #selector(buttonAction),
                         for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    fileprivate func createAnotions() {
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.9428)
        annotation1.title = "Ice"
        mapView.addAnnotation(annotation1)
        
        let annotation2 = MKPointAnnotation()
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.96)
        annotation1.title = "Tree in the road"
        mapView.addAnnotation(annotation2)
        
        let annotation3 = MKPointAnnotation()
        annotation3.coordinate = CLLocationCoordinate2D(latitude: 40.45, longitude: -79.93)
        annotation3.title = "Rock"
        mapView.addAnnotation(annotation3)
        
        let annotation4 = MKPointAnnotation()
        annotation4.coordinate = CLLocationCoordinate2D(latitude: 40.44, longitude: -79.95)
        annotation4.title = "Ice"
        mapView.addAnnotation(annotation4)
        
        let region = MKCoordinateRegion(center: annotation1.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 20, y: 50, width: view.frame.self.width-40, height: view.frame.size.height-100)
        locationManager.delegate = self
        mapView.delegate = self
        getDirections()
        getDirections2()
        createButton()
        createNotifyButton()
        createAnotions()
        ///---MARK:
        createMusicPlayButton()
        ///---MARK:
        

    }
    ///---MARK:
    func createMusicPlayButton() {
        self.view.addSubview(self.musicButton)
        self.view.bringSubviewToFront(musicButton)
    }
    ///---MARK:
    
    private func createButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.center = CGPoint(x: view.center.x, y: view.frame.size.height-70)
//        button.cornerRadius = 12
//        button.icon = .arrowOutline
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        self.locationManager.stopUpdatingLocation()
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // ask for permition for location
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else {
            // show alert letting the user kow they have to turn on
        }
    }
    
    func checkLocationAuthorization() {
        
    }
    
    @objc
        func buttonAction() {
            if (notification == false) {
                self.showToast(message: "Notification Mode On", font: .systemFont(ofSize: 12.0))
                self.notification = !notification

            } else {
                self.showToast(message: "Notification Mode Off", font: .systemFont(ofSize: 12.0))
                self.notification = !notification

            }
//            print("Notification Button pressed")
        }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 90, y: self.view.frame.size.height - 400, width: 200, height: 60))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 6.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func getDirections() {
        let request = MKDirections.Request()
        // Source
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.45, longitude: -79.93))
        request.source = MKMapItem(placemark: sourcePlaceMark)
        // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.9428))
        request.destination = MKMapItem(placemark: destPlaceMark)
        // Transport Types
        request.transportType = [.automobile, .walking]

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }

            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)

            // …
        }

    }
    
    func getDirections2() {
        let request = MKDirections.Request()
        // Source
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.445, longitude: -79.965))
        request.source = MKMapItem(placemark: sourcePlaceMark)
        // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.44, longitude: -79.968))
        request.destination = MKMapItem(placemark: destPlaceMark)
        // Transport Types
        request.transportType = [.automobile, .walking]

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }

            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)

            // …
        }

    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        // Set the color for the line
        renderer.strokeColor = .red
        return renderer
    }

}

//extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    //
//    }
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        //
//    }
//}


///---MARK:
extension ViewController:AVAudioPlayerDelegate {
    
   @objc func   playMusic(){
        guard let soundFileURL = Bundle.main.url(
            forResource: "test", withExtension: "mp3"
        ) else  {
            debugPrint("audio can not found")
            return
        }
           let  err = try? AVAudioSession.sharedInstance().setCategory(
               AVAudioSession.Category.playback,
               options: AVAudioSession.CategoryOptions.mixWithOthers
            )
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                // Handle error
                debugPrint(error)
            }
           player =  try? AVAudioPlayer(contentsOf: soundFileURL)
            player?.delegate = self
           player?.play()
        musicButton.setTitle("Playing", for: .normal)
        
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            musicButton.setTitle("PlayMusic", for: .normal)
        }
    }
}
///---MARK:
