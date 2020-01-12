//
//  userTableViewController.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/30/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit
import Firebase

class userTableViewController: UITableViewController {

    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var friendArray = Array(repeating: Friend(), count: User.friendEmailArray.count)
    let alert: UIAlertController = {
        let configuredAlert = UIAlertController(title: "Oops!!!!!", message: "Friend already exists", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        configuredAlert.addAction(cancel)
        return configuredAlert
    }()

    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var personalPhoto: myButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    //MARK: - VC life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setUpCurrentUser()
        setUpFriends()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpCurrentUser()
    }
    
    func setUpCurrentUser() {
        userName.text = User.username!
        if User.image == nil {
            print("--------------------------------------------")
        }
        let image = User.image ?? UIImage(named: "userImagePlaceholder")
        personalPhoto.setImage(image, for: .normal)
    }
    
    
    
    func setUpFriends() {
        
        
        for (i, email) in User.friendEmailArray.enumerated() {
            db.collection(K.FStore.collectionName).document(email).getDocument { (document, error) in
                if error != nil {
                    print("[Error][loginViewController] fail to fetch login user info")
                }
                else {
                    guard let username = document?.data()?[K.FStore.usernameField] as?String,
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
                    let friend = Friend(name: username, status: status, email: email, image: nil)
                    self.friendArray[i] = friend
                    self.downloadFriendPhoto(name: username, row: i)
                    
                }
            }
        }
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    func downloadFriendPhoto(name: String, row: Int) {
        let imageRef = storageRef.child("\(name)/image.jpg")
        imageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error {
                print("[Error][loginViewController] download image: \(error)")
                User.image = UIImage(named: "userImagePlaceholder")
            }
            else {
                self.friendArray[row].image = UIImage(data: data!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (User.friendEmailArray != []) ? User.friendEmailArray.count : 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! userTableViewCell
    

        // Configure the cell...
        cell.friendPhoto?.image = (friendArray[indexPath.row].image != nil) ? friendArray[indexPath.row].image! : UIImage(named: "userImagePlaceholder")
        
        cell.friendName.text = friendArray[indexPath.row].name ?? "?"
        cell.friendStatus.text = friendArray[indexPath.row].status ?? "?"
        
        
        return cell
    }
    
    //MARK: - Edit table view

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let index = User.friendEmailArray.firstIndex(of: User.friendEmailArray[indexPath.row]) {
                User.friendEmailArray.remove(at: index)
                updateFriendListInDatabase(emails: User.friendEmailArray)
                friendArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }    
    }

    func updateFriendListInDatabase(emails: [String]) {
        
        let docData: [String:Any] = [
            K.FStore.friendsField: emails
        ]
        
        db.collection(K.FStore.collectionName).document(User.email!).updateData(docData) { err in
            if let err = err {
                print ("[Error][map1ViewController] fail to update coord info: \(err)")
            }
            else {
                print("[Success][map1ViewController] succeed to update coord info")
            }
        }
        
        
    }
    
    
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        
        if let email = emailTextField.text {
            
            guard User.friendEmailArray.firstIndex(of: email) == nil else {
                alert.message = "friend already exists"
                self.emailTextField.text = ""
                self.present(alert, animated: true)
                return
            }
            
            self.db.collection(K.FStore.collectionName).getDocuments { (documentSnapshot, error) in
                if error != nil {
                    print("[Error][userTableViewController] fail to retrieve collection info")
                }
                else {
                    if let documents = documentSnapshot?.documents {
                        for doc in documents {
                            if doc.documentID == email {
                                User.friendEmailArray.append(email)
                                self.updateFriendListInDatabase(emails: User.friendEmailArray)
                                let data = doc.data()
                                let newFriend = Friend(name: data[K.FStore.usernameField] as! String, status: data[K.FStore.statusField] as! String, email: email, image: UIImage(named: "userImagePlaceholder"))
                                self.friendArray.append(newFriend)
                                self.downloadFriendPhoto(name: newFriend.name!, row: self.friendArray.count-1)
                                self.addNewRow()
                                return
                            }
                        }
                        self.alert.message = "no such user"
                        self.emailTextField.text = ""
                        self.present(self.alert, animated: true)
                    }
                }
            }
        }
    }
    
    func addNewRow() {
        let indexPath = IndexPath(row: User.friendEmailArray.count-1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        emailTextField.text = ""
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
//    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
