//
//  AddLocationVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit
import MapKit

class AddLocationVC: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
   
    var coordinate: CLLocationCoordinate2D? = nil
    var location: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationTextField.layer.cornerRadius = 5
        websiteTextField.layer.cornerRadius = 5
        findLocationButton.layer.cornerRadius = 5
    }
    func showFailure(message: String) {
        let alertVC = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    @IBAction func findLocationTapped(_ sender: UIButton) {
       // performSegue(withIdentifier: "CompletedLogIn", sender: true)
        guard let location = locationTextField.text else{
           //displayAlert(title: "Error", message: "Enter a location!")
            showFailure(message: "Enter a location")
            return
        }
        guard websiteTextField.text != nil else {
           showFailure(message: "Enter a website")
            return
        }
        findLocation(location)
    }
    
    func seaerchingForLocation(_ status: Bool){
        locationTextField.isEnabled = !status
        websiteTextField.isEnabled = !status
        findLocationButton.isEnabled = !status
    }
    
    func findLocation(_ location: String){
        self.seaerchingForLocation(true)
        CLGeocoder().geocodeAddressString(location) {(placeMark, error) in
            guard error == nil else {
                //error
                self.showFailure(message: "Location Not Found!")
                self.seaerchingForLocation(false)
                return
            }
            let coordinate = placeMark?.first!.location!.coordinate
            self.coordinate = coordinate
            self.location = location
            self.performSegue(withIdentifier: "locationFound", sender: nil)
            self.seaerchingForLocation(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "locationFound"){
            let finishAddLocation = (segue.destination as! FinishAddLocationVC)
            finishAddLocation.coordinate = coordinate
            finishAddLocation.location = location
            finishAddLocation.website = websiteTextField.text!
        }
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
     
                self.dismiss(animated: true, completion: nil)
               
            }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


