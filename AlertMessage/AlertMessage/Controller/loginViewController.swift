//
//  loginViewController.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/30/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import FirebaseAuth
//import FirebaseStorage


class loginViewController: UIViewController {
    
    let db = Firestore.firestore()
    // Buttons
    @IBOutlet weak var LoginButton: myButton!
    @IBOutlet weak var SignupButton: myButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    
    // Textfields
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    // Labels
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var videoPlayer:AVPlayer?
    var videoPlayerLayer:AVPlayerLayer?
    
    //MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        // set up video in the background
        setUpVideo()
    }
    
    func setUpVideo() {
        
        let videoPath = Bundle.main.path(forResource: "loginvd", ofType: "mp4")
        
        guard videoPath != nil else {
            return
        }
        
        let url = URL(fileURLWithPath: videoPath!)
        let item = AVPlayerItem(url: url)
        videoPlayer = AVPlayer(playerItem: item)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        videoPlayerLayer!.frame = view.bounds
        videoPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPlayer?.playImmediately(atRate: 0.8)
        
    }
    
    //MARK: - Validation
    
    /*
     function that checks all fields are filled, emails is valid, and password is secure
     input: none
     output: string indicating if fields are valid, nil for valid, other messsages for non valid
     */
    func validateFields() -> String? {
        
        // check that all fields are filled
        if emailTextfield.text?.trimmingCharacters(in: .whitespaces) == "" || passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        // email address and password without spaces and nextline characters
        let cleanedEmail = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // check if the email address is valid
        if isEmailValid(cleanedEmail) == false {
            return "Please make sure your email address is correct."
        }
        
        // check if the password is secure
        if isPasswordValid(cleanedPassword) == false{
            return "Please make sure your password is at least 10 characters long, contains a number and a special character."
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
    
    //MARK: - Login logic
    
    @IBAction func loginButtonTapped(_ sender: myButton) {
        
        // validate the fields
        let error = validateFields()
        
        // error in fields
        if error != nil {
            showError(error!)
        }
            
            // no error in fields
        else {
            
            // create cleaned versions of the data
            let email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in the User
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    // Couldn't sign in
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }
                    
                else {
                    self.errorLabel.alpha = 0 //login on succeed, erase the prompt info

                    self.passwordTextfield.text = ""
                    fetchCurrentUserInfo(email: email)
                
            }
        }
    }
        
        func fetchCurrentUserInfo(email: String) {
                User.email = email
                self.db.collection(K.FStore.collectionName).document(User.email!).getDocument { (document, error) in
                    if error != nil {
                        print("[Error][loginViewController] fail to fetch login user info")
                    }
                    else {
                        guard let username = document?.data()?[K.FStore.usernameField] as?String,
                            let phone = document?.data()?[K.FStore.phoneField] as?String,
                            let status = document?.data()?[K.FStore.statusField] as?String
                            else {
                                do {
                                    try Auth.auth().signOut()
                                    print("[On success] succeed to sign out")
                                }
                            catch {
                                print("[On error] fail to sign out")
                            }
                            return;
                        }
                        
                        User.username = username
                        User.phone = phone
                        if status == "offline" {
                            User.status = User.Status(rawValue: "normal")!
                            let docData: [String:String] = [
                                 K.FStore.statusField: "normal"
                            ]
                             
                            self.db.collection(K.FStore.collectionName).document(User.email!).updateData(docData) { err in
                                if let err = err {
                                    print ("[Error][map1ViewController] fail to update status info: \(err)")
                                }
                                else {
                                    print("[Success][map1ViewController] succeed to update status info")
                                }
                            }
                        }
                        else {
                            User.status = User.Status(rawValue: status)!
                        }
                        if let friendArray = (document?.data()?[K.FStore.friendsField] as? [String]) {
                            User.friendEmailArray = friendArray
                        }
                        
                        //self.transitionToTest()
                        self.downloadPersonalPhotoThenDoTransition()

                    }
                }
            }
        }
    
    func downloadPersonalPhotoThenDoTransition() {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(User.username!)/image.jpg")
        imageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error {
                print("[Error][loginViewController] download image: \(error)")
                User.image = UIImage(named: "userImagePlaceholder")
            }
            else {
                User.image = UIImage(data: data!)
            }
            
//            if User.image == nil {
//                print("no image")
//            }
//            else {
//                print("image for user")
//            }
//
//            print("----------user: \(User.username!)--------------")
            
            self.transitionToHome()
        }
    }
    
    
    /*
     function that displays error
     */
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    
    
    /*
     function that transites to home screen
     */
    func transitionToHome() {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: "home") as! UITabBarController
        home.modalPresentationStyle = .fullScreen
        present(home, animated: true, completion: nil)
    }
    
    func transitionToTest() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: "test") 
        //home.modalPresentationStyle = .fullScreen
        present(home, animated: true, completion: nil)
    }
    
    //MARK: - Logout
    @IBAction func backToLogin(_ sender: UIStoryboardSegue) {
        do {
            try Auth.auth().signOut()
            //Upload status before sign out
            let lastStatus = (User.status == .normal) ? "offline" : User.status.description()
            let docData: [String:String] = [
                 K.FStore.statusField: lastStatus
            ]
             
            db.collection(K.FStore.collectionName).document(User.email!).updateData(docData) { err in
                if let err = err {
                    print ("[Error][map1ViewController] fail to update status info: \(err)")
                }
                else {
                    print("[Success][map1ViewController] succeed to update status info")
                }
            }
            
            //Clear user info
            User.clear()
            print("[On success] succeed to sign out")
        }
        catch {
            print("[On error] fail to sign out")
        }
    }
    
}
