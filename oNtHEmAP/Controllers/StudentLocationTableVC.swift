//
//  StudentLocationTableVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit

class StudentLocationTableVC: UITableViewController {

    var students = [StudentLocation]()
    
    let cellReuseIdentifier = "StudentInfoReuseIdentifier"
//    let studentInfo = [
//        ["text" : "Do", "detail" : "A deer. A female deer."],
//        ["text" : "Re", "detail" : "A drop of golden sun."],
//        ["text" : "Mi", "detail" : "A name, I call myself."],
//        ["text" : "Fa", "detail" : "A long long way to run."],
//        ["text" : "So", "detail" : "A needle pulling thread."],
//        ["text" : "La", "detail" : "A note to follow So."],
//        ["text" : "Ti", "detail" : "A drink with jam and bread."]
//    ]
//    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        //tableView.rowHeight = .maximumMagnitude(<#T##x: CGFloat##CGFloat#>, <#T##y: CGFloat##CGFloat#>)
    }
    
    //MARK : -from another one
    func refreshStudentList () {
        OMTCilent.getStudentLocation(completion: handleGetStudentLocation(studentLocations:error:))
    
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
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
     
                self.dismiss(animated: true, completion: nil)
               
            }
   

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInfoList.studentInfoList.count
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell =  tableView.dequeueReusableCell(withIdentifier: "StudentInfoReuseIdentifier")!
        
        let student = StudentInfoList.studentInfoList[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentInfoList.studentInfoList[indexPath.row]
        UIApplication.shared.open(URL(string: student.mediaURL)!, options: [:], completionHandler: nil)
        
    }

}
