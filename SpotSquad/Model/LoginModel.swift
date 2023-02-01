//
//  LoginModel.swift
//  CoffeeFetch
//
//  Created by segev perets on 18/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - Login Delegate Protocol & Default funcs
protocol LoginDelegate : LoginViewController {
    func textFieldDidReturnError(textField:UITextField, error:Error)
}
extension LoginDelegate {
    
    
    /**
     Checks if textField contains valid text.
     - checks if text isn't nil
     - isn't empty
     - and contains other characters other than Space .
     */
    func textFieldIsValid (_ textField:UITextField) -> Bool {
        if let text = textField.text, text.contains(where: {$0 != Character(" ")}) && !text.isEmpty {
            return true
        } else {
            flickerTextField(textField)
            return false
        }
    }
    /**
     LoginDelegate protocol func, flicker given textfield in red if had errors .
     */
    func textFieldDidReturnError(textField:UITextField, error:Error) {
        let shortErrorDescription = error.localizedDescription
        let alert = UIAlertController(title: "Error ", message: shortErrorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            self.flickerTextField(textField)
        }))
        present(alert, animated: true)
    }
    
    private func flickerTextField (_ textField:UITextField) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        
        UIView.animate(withDuration: 0.1) {
            textField.backgroundColor = .systemRed
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                textField.backgroundColor = .white
            }
            textField.becomeFirstResponder()
        }
        
    }
}


// MARK: - LoginModel
class LoginModel {
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()

    var email : String?
    var password : String?
    var userName : String?
//    var imageUrl : URL?
    var imageData : Data?
    
    weak var delegate : LoginDelegate?
    
    // MARK: - picker
    
    func alertUserIfProfilePhotoIsNil () -> UIAlertController? {
        if delegate?.imageData == nil {
            //explain with an error
            let alert = UIAlertController(title: "Please select an image from your library.", message: "You cannot procceed without a photo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            return alert
        } else {
            return nil
        }
    }

    
    
    // MARK: - Register & Login
    /**
     Register and update User.displayName .
     - calls updateUserInfo()
     - and then calls FB.shared.addUserToFBCollection()
     -
     */
    func register () {
        print(#function)
        
        if let email, let password, let delegate {
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else {return}
                
                if let error = error {
                    print(error.localizedDescription)
                    if error.localizedDescription.contains("email") {
                        delegate.textFieldDidReturnError(textField: delegate.emailTextField, error: error)
                    } else if error.localizedDescription.contains("password") {
                        delegate.textFieldDidReturnError(textField: delegate.passwordTextField, error: error)
                    }
                    
                    
                } else if let authResult {
                    
                    FB.shared.currentUser = authResult.user
                    
                    guard delegate.imageData != nil else {fatalError("No image!")}
                    self.savePhoto(delegate.imageData!, uid: authResult.user.uid)
                                                            
                }
            }
        }
    }
    
    /**
     - saves the photo's data in firebase storage.
     - calls updateUserInfo()
     - updateUserInfo() calls addUserToFBCollection() that sends notification to VC to updateUI.
     */
     private func savePhoto (_ photoData:Data, uid:String) {
         print(#function)
         
         let storagePath = storage.child("profileImages/\(uid)/photo.jpeg")
         
        storagePath.putData(photoData) {[weak self] metaData, error in
            guard let self = self else {return}
            if let error {
                print("Error while saving photo! : \(error)")
            } else if metaData != nil {
                
                storagePath.downloadURL { url, error in
                    if let url, error == nil {
                        
                        self.updateUserInfo(to: self.userName!, user: FB.shared.currentUser!, photoUrl: url)
                    }
                }
            } else {
                print("Error while saving photo!")
            }
        }
    }
    
    
    /**
     Being called from register(), with userName!.
     */
    private func updateUserInfo (to userName:String, user:User, photoUrl: URL) {
        
        print(#function)
                
        let changeRequest = user.createProfileChangeRequest()
        
        //change what needed to be changed
        changeRequest.displayName = userName
        
        changeRequest.photoURL = photoUrl
        
        //maybe change more ..
        
        changeRequest.commitChanges { [weak self] error in
            guard let self = self else {return}
            if let error {
                print("Error while changing userName : \(error)")
            } else {
                print("successfuly updated user name")
                self.addUserToFBCollection(user)
            }
        }
        
    }
    
    private func addUserToFBCollection (_ user:User) {
        
        let dispatchGroup = DispatchGroup()
        
        
        if let userName = user.displayName, let email = user.email {
            
            dispatchGroup.enter()
            
            let currentUserDocument = db.collection("users").document(user.uid)
            
            currentUserDocument.getDocument { document, error in
                
                if let document = document, document.exists {
                    
                    currentUserDocument.updateData(["email":email,"username":userName])
                    
                    dispatchGroup.leave()
                } else {

                    currentUserDocument.setData(["email":email,"username":userName])

                    dispatchGroup.leave()
                }
                
            }
        } else {fatalError("\(#function) Failed. Something went wrong!")}
        
        
        dispatchGroup.notify(queue: .main) {
            
            self.delegate?.performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    
    func signIn () {
        print(#function)
        if let email, let password, let delegate {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    ;#warning("move logic away from here")

                    if error.localizedDescription.contains("password") {
                        delegate.textFieldDidReturnError(textField: delegate.passwordTextField, error: error)
                    } else  {
                        delegate.textFieldDidReturnError(textField: delegate.emailTextField, error: error)
                    }
                    
                } else if let authResult {
                    
                    FB.shared.currentUser = authResult.user
                    
                    delegate.performSegue(withIdentifier: "toMain", sender: self)
                    
                    //Do not continue from here! this runs before the VC.viewDidLoad and isnt quick enaugh to set listener.
                }
                
            }
        }
    }
    
    
    
    
    
}
