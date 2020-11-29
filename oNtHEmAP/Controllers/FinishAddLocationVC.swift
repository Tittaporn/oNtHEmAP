//
//  FinishAddLocationVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit
import MapKit

class FinishAddLocationVC: UIViewController, MKMapViewDelegate {
    
    // MARK: Variables
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var newStudentLocationAtF: StudentLocation!
    var newLatitudeAtF:CLLocationDegrees!
    var newLongitudeAtF:CLLocationDegrees!
    let latDelta:CLLocationDegrees = 0.05
    let lonDelta:CLLocationDegrees = 0.05
    
    //MARK : LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        print("newStudentLocationAtF in FinishAddLocationVC is :::::::\(String(describing: newStudentLocationAtF))")
        if newLatitudeAtF == nil || newLongitudeAtF == nil {
            print("No newLatideAtF or newLongitudeAtF")
        } else {
            dropPinOnLocation()
        }
        setFinishindAddLocation(false)
    }
    
    //MARK : MKMapViewDelegate
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
    
    //MARK : Actions
    @IBAction func finishTapped(_ sender: UIButton) {
        setFinishindAddLocation(true)
        if OTMManager.otmManager.objectId == nil {
            OMTClient.addLocation(newInfo: newStudentLocationAtF, completion: handleFinishAddLocationResponse(success:error:))
            print("There is objectId after addLocation on FinishAddLocationVC ::: >>\(String(describing: OTMManager.otmManager.objectId))")
            updateStudentLocation()
        } else {
            updateStudentLocation()
        }
    }
    
    //MARK : Functions
    func updateStudentLocation () {
        guard let objectId = OTMManager.otmManager.objectId else {
            print("Error !!There is no ojectId in OTMManager.otmManager.objectId.")
            return
        }
        OMTClient.updateStudentLocation(objectId: objectId, newStudentLocation: newStudentLocationAtF) { (error) in
            if error != nil {
                self.showFinishAddLocationError(message: "Could not updateStudent Location")
                print("Could not updateStudent Location")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("Successful updateStudent Location")
            
        }
    }
    
    func handleFinishAddLocationResponse(success: Bool, error: Error?) {
        if success {
            print("Successful Finish Add Location")
            dismiss(animated: true, completion: nil)
        } else {
            print("Unsuccessful Finish Add Location")
            showFinishAddLocationError(message: error?.localizedDescription ?? "")
            dismiss(animated: true, completion: nil)
        }
    }
    
    func showFinishAddLocationError(message: String) {
        let alertVC = UIAlertController(
            title: "Finish Add Location Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func dropPinOnLocation() {
        let coordinate = CLLocationCoordinate2D(latitude: newLatitudeAtF, longitude: newLongitudeAtF)
        let firstName = newStudentLocationAtF?.firstName
        let lastName =  newStudentLocationAtF?.lastName
        let span = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: newLatitudeAtF, longitude: newLongitudeAtF), span: span)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = coordinate
        dropPin.title = "\(String(describing: firstName!)) \(String(describing: lastName!))"
        dropPin.subtitle = newStudentLocationAtF?.mediaURL
        mapView.addAnnotation(dropPin)
        mapView.setRegion(region, animated: false)
    }
    
    func setFinishindAddLocation(_ status: Bool){
        if status {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                self.finishButton.isEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.finishButton.isEnabled = true
            }
        }
    }
}



