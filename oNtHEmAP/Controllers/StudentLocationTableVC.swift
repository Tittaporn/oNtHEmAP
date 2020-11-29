//
//  StudentLocationTableVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit

class StudentLocationTableVC: UITableViewController {
    
    //MARK : Variables
    var students = [StudentLocation]()
    let cellReuseIdentifier = "StudentInfoReuseIdentifier"
    
    //MARK : LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    //MARK : Functions
    func refreshStudentList () {
        OMTClient.getStudentLocation(completion: handleGetStudentLocation(studentLocations:error:))
    }
    
    func handleGetStudentLocation(studentLocations: [StudentLocation], error: Error?) {
        if error != nil {
            showFailure(message: error?.localizedDescription ?? "")
        } else {
            StudentInfoList.studentInfoList = studentLocations
            self.showStudentListOnTable()
        }
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(
            title: "Error!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func showStudentListOnTable() {
        refreshStudentList()
        self.tableView.reloadData()
    }
    
    //MARK : Actions
    @IBAction func logout(_ sender: UIBarButtonItem) {
        OMTClient.deleteSessionForLogOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateLocation(_ sender: UIBarButtonItem) {
        OMTClient.updateLocation()
    }
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInfoList.studentInfoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "StudentInfoReuseIdentifier")
        let student = StudentInfoList.studentInfoList[(indexPath as NSIndexPath).row]
        cell?.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell?.textLabel?.textColor = .blue
        cell?.textLabel?.font =  UIFont(name: "Apple Color Emoji", size: 14)!
        cell?.detailTextLabel?.text = "\(student.mediaURL)"
        cell?.detailTextLabel?.textColor = .blue
        cell?.detailTextLabel?.font =  UIFont(name: "Apple Color Emoji", size: 12)!
        cell?.imageView?.image = UIImage(named: "icon_pin")
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentInfoList.studentInfoList[indexPath.row]
        UIApplication.shared.open(URL(string: student.mediaURL)!, options: [:], completionHandler: nil)
    }
}
