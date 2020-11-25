//
//  StudentLocationMapVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit
import MapKit

class StudentLocationMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [StudentLocation]()
    var annotations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStudentLocation()

        // Do any additional setup after loading the view.
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
//        var locations = refreshStudentLocation()
//
//        // We will create an MKPointAnnotation for each dictionary in "locations". The
//        // point annotations will be stored in this array, and then provided to the map view.
//        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        showLocationOnMap()
        
     
    }
    
    
    //MARK : -from another one
    func refreshStudentLocation () {
        OMTCilent.getStudentLocation(completion: handleGetStudentLocation(studentLocations:error:))
    
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
//        for studentInfo in StudentInfoList.studentInfoList {
//            let studentLocation = CLLocationCoordinate2DMake(studentInfo.latitude, studentInfo.longitude)
//            let dropPin = MKPointAnnotation()
//            dropPin.coordinate = studentLocation
//            dropPin.title = studentInfo.firstName + " " + studentInfo.lastName
//            dropPin.subtitle = studentInfo.mediaURL
//            mapView.addAnnotation(dropPin)
//
//
//        }
        refreshStudentLocation()
        //var annotations = [MKPointAnnotation]()
        
        for studentInfo in StudentInfoList.studentInfoList {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(studentInfo.latitude )
            let long = CLLocationDegrees(studentInfo.longitude )
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentInfo.firstName
            let last = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    
    }
    
  
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
     
                self.dismiss(animated: true, completion: nil)
               
            }
    }



// MARK: - MKMapViewDelegate

// Here we create a view with a "right callout accessory view". You might choose to look into other
// decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
// method in TableViewDataSource.
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.pinTintColor = .green
        pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
        pinView!.annotation = annotation
    }
    
    return pinView
}


// This delegate method is implemented to respond to taps. It opens the system browser
// to the URL specified in the annotationViews subtitle property.
func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
        //let app = UIApplication.shared
        if let toOpen = view.annotation?.subtitle! {
           // app.openURL(URL(string: toOpen)!)
            UIApplication.shared.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
        }
    }
}

    /* UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


