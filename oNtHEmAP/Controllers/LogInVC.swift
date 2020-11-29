//
//  LoginVC.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/17/20.
//

import UIKit

class LogInVC: UIViewController, UITextFieldDelegate {
    
    //MARK : Variables
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let signUpUrl = OMTClient.Endpoints.signUp.url
    var emailFieldIsEmpty: Bool = true
    var passwordFieldIsEmpty: Bool = true
    
    //MARK : LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
        setLogginIn(false)
    }
    
    //MARK : Actions
    @IBAction func signUpTapped(_ sender: UIButton){
        setLogginIn(true)
        UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        setLogginIn(true)
        OMTClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion:  handleLoginResponse(success:error:))
    }
    
    //MARK : Functions
    func handleLoginResponse(success: Bool, error: Error?) {
        setLogginIn(false)
        if success {
            performSegue(withIdentifier: "CompletedLogIn", sender: true)
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func setLogginIn(_ logginIn: Bool){
        logginIn ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = !logginIn
        self.signUpButton.isEnabled = !logginIn
        emailTextField.isEnabled = !logginIn
        passwordTextField.isEnabled = !logginIn
        loginButton.isEnabled = !logginIn
        signUpButton.isEnabled = !logginIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(
            title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK.", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    //MARK : TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            let currenText = emailTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                emailFieldIsEmpty = true
            } else {
                emailFieldIsEmpty = false
            }
        }
        
        if textField == passwordTextField {
            let currenText = passwordTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                passwordFieldIsEmpty = true
            } else {
                passwordFieldIsEmpty = false
            }
        }
        
        if emailFieldIsEmpty == false && passwordFieldIsEmpty == false {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        loginButton.isEnabled = false
        
        if textField == emailTextField {
            emailFieldIsEmpty = true
        }
        if textField == passwordTextField {
            passwordFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginTapped(loginButton)
        }
        return true
    }
    
}


