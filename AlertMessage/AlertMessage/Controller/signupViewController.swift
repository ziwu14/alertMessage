//
//  signupViewController.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/30/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class signupViewController: UIViewController {
    
    let db = Firestore.firestore()
    // Textfields
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var pwReconfirmTextfield: UITextField!
    
    
    // Buttons
    @IBOutlet weak var createButton: myButton!
    @IBOutlet weak var resetButton: myButton!
    
    // Labels
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK: - VC life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        usernameTextfield.resignFirstResponder()
        emailTextfield.resignFirstResponder()
        phoneTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        pwReconfirmTextfield.resignFirstResponder()
    }
    
    
    
    
    /*
     Action after signUp Button is tapped
     check if fields are valid
     create user
     save user to the database
     */
    @IBAction func createButtonTapped(_ sender: UIButton) {
        
        // validate the fields
        let error = validateFields()
        
        // error in fields
        if error != nil {
            showError(error!)
        }
            
            // no error in fields
        else {
            
            // create cleaned versions of the data
            User.username = usernameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            User.phone = phoneTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            User.email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            
            // create the user
            // completion handler will check if the user is successfully created
            Auth.auth().createUser(withEmail: User.email!, password: password) { (result, err) in
                
                // check for errors
                if (err != nil) {
                    self.showError(err!.localizedDescription)
                }
                    
                else {
                    
                    let docData: [String:String] = [
                        K.FStore.phoneField: User.phone!,
                        K.FStore.usernameField: User.username!,
                        K.FStore.statusField: User.status.description()
                    ]
                    
                    self.db.collection(K.FStore.collectionName).document(User.email!).setData(docData) { err in
                        if let err = err {
                            print("[Error][signupViewController] fail to update user info to firestore")
                            
                        }
                        else {
                            print ("[Success] succeed to update user info to firestore")
                        }
                    }
                    //clear text field
                    self.passwordTextfield.text = ""
                    // transition to the home screen
                    self.transitionToHome()
                    
                }
            }
        }
    }
    
    /*
     function that checks all fields are filled, emails is valid, and password is secure
     input: none
     output: string indicating if fields are valid, nil for valid, other messsages for non valid
     */
    
    //MARK: - Validation
    
    func validateFields() -> String? {
        
        // check that all fields are filled
        if usernameTextfield.text?.trimmingCharacters(in: .whitespaces) == "" || emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || phoneTextfield.text?.trimmingCharacters(in: .whitespaces) == "" || passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || pwReconfirmTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        
        // email address and password without spaces and nextline characters
        let cleanedEmail = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // check if the email address is valid
        if isEmailValid(cleanedEmail) == false {
            return "Please make sure your email address contains the @ sign and is valid."
        }
        
        // check if the password is secure
        if isPasswordValid(cleanedPassword) == false{
            return "Please make sure your password is at least 10 characters long, contains a number and a special character."
        }
        
        // check if password and reconfirmed password are the same
        if passwordTextfield.text != pwReconfirmTextfield.text {
            return "Please make sure your password is correct."
        }
        
        // fields filled and all valid
        return nil
        
    }
    
    
    
    /*
     function that checks email address is valid
     input: email address in string
     output: valid or not, bool
     */
    func isEmailValid(_ email: String) -> Bool {
        let emailRegExpPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailRegex = NSRegularExpression(emailRegExpPattern)
        return emailRegex.matches(email)
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegExpPattern = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{10,}"
        let passwordRegex = NSRegularExpression(passwordRegExpPattern)
        return passwordRegex.matches(password)
    }
    
    /*
     function that displays error
     */
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    }
    */
    
    /*
     function that transites to home screen
     */
    func transitionToHome() {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: "home") as! UITabBarController
        home.modalPresentationStyle = .fullScreen
        present(home, animated: true, completion: nil)
    }
    
    
}
