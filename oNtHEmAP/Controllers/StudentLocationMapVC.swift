//
//  StudentLocationMapVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit
import MapKit

class StudentLocationMapVC: UIViewController, MKMapViewDelegate {
    
    //MARK : Variables
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [StudentLocation]()
    var annotations = [MKPointAnnotation]()
    
    //MARK : LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStudentLocation()
        showLocationOnMap()
        mapView.delegate = self
    }
    
    
    //MARK : Functions
    func refreshStudentLocation () {
        OMTClient.getStudentLocation(completion: handleGetStudentLocation(studentLocations:error:))
        
    }
    
    func handleGetStudentLocation(studentLocations: [StudentLocation], error: Error?) {
        if error != nil {
            showFailure(message: error?.localizedDescription ?? "")
        } else {
            StudentInfoList.studentInfoList = studentLocations
            self.showLocationOnMap()
        }
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(
            title: "Error!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func showLocationOnMap() {
        refreshStudentLocation()
        for studentInfo in StudentInfoList.studentInfoList {
            let lat = CLLocationDegrees(studentInfo.latitude )
            let long = CLLocationDegrees(studentInfo.longitude )
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentInfo.firstName
            let last = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    //MARK : Actions
    @IBAction func updateLocation(_ sender: UIBarButtonItem) {
        OMTClient.updateLocation()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        OMTClient.deleteSessionForLogOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let studentUrl = view.annotation?.subtitle! {
                UIApplication.shared.open(URL(string: studentUrl)!, options: [:], completionHandler: nil)
                
            }
        }
    }
}


