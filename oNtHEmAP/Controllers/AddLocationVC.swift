//
//  AddLocationVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit
import MapKit

class AddLocationVC: UIViewController {
    
    // MARK: Variables
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let geocoder = CLGeocoder()
    var studentLocation: StudentLocation!
    var latitude:CLLocationDegrees!
    var longitude:CLLocationDegrees!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setSeaerchingForLocation(false)
        activityIndicator.isHidden = true
    }
    
    //MARK : Functions
    func setSeaerchingForLocation(_ status: Bool){
        locationTextField.isEnabled = !status
        websiteTextField.isEnabled = !status
        findLocationButton.isEnabled = !status
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let finishAddLocationController = segue.destination as! FinishAddLocationVC
        finishAddLocationController.newStudentLocationAtF = studentLocation
        finishAddLocationController.newLatitudeAtF = latitude
        finishAddLocationController.newLongitudeAtF = longitude
    }
    
    func showAddLocationError(message: String) {
        let alertVC = UIAlertController(
            title: "Add Location Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func findLocationTapped(_ sender: UIButton) {
        setSeaerchingForLocation(true)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) in
            guard let placemarks = placemarks else {
                DispatchQueue.main.async {
                    self.setSeaerchingForLocation(false)
                    self.showAddLocationError(message: error?.localizedDescription ?? "" )
                }
                return
            }
            let location = placemarks.first?.location
            let latitude = location?.coordinate.latitude
            let longitude = location?.coordinate.longitude
            let mediaURL = self.websiteTextField.text!
            
            DispatchQueue.main.async {
                if self.studentLocation == nil {
                    self.studentLocation = StudentLocation(objectId: nil, uniqueKey: OMTClient.Auth.key, firstName: OMTClient.Auth.firstName, lastName: OMTClient.Auth.lastName, mapString: self.locationTextField.text!, mediaURL: mediaURL, latitude: latitude!, longitude: longitude!, createdAt: nil, updatedAt: nil)
                } else {
                    print("No studentLocation In AddLocationVC")
                }
                
                self.latitude = latitude
                self.longitude = longitude
                self.setSeaerchingForLocation(false)
                self.performSegue(withIdentifier: "locationFound", sender: self)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


