//
//  profileViewController.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/30/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseStorage

class profileViewController: UIViewController {
    
    
    
    let storageRef = Storage.storage().reference()

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var personalImageView: myButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        emailLabel.text = User.email!
        phoneLabel.text = User.phone!
        let image = User.image ?? UIImage(named: "userImagePlaceholder")
        personalImageView.setImage(image, for: .normal)
    }
    

    @IBAction func uploadImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func backToLoginPage(_ sender: Any) {
        self.performSegue(withIdentifier: K.signoutSegueIdentifier, sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension profileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let localImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            personalImageView.setImage(localImage, for: .normal)
            User.image = localImage
            uploadPhotoImage(image: localImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadPhotoImage(image: UIImage) {
        
        let imageRef = storageRef.child("\(User.username!)/image.jpg")
        if let uploadData = image.jpegData(compressionQuality: 0.25) {
            imageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                
                if error != nil {
                    print("[Error][profileViewController]: fail to upload image")
                    return
                }
                print("[Success][profileViewController]: succeed to upload image")
//                imageRef.downloadURL {
//                    (url, error) in
//                    guard let downloadURL = url else {
//                      // Uh-oh, an error occurred!
//                        print("[Error][profileViewController] downloadURL fails")
//                        return
//                    }
//                    User.imageURL = url
//                }
            })
        }
    }
}
