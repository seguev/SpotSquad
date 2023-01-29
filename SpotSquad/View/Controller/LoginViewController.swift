//
//  LoginViewController.swift
//  CoffeeFetch
//
//  Created by segev perets on 11/01/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate , LoginDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    
    @IBOutlet weak var albumButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainButtonOutlet: UIButton!
    
    var login = LoginModel()
    enum Mode : String {
        case register = "Register"
        case login = "Log In"
    }
    
    let picker = UIImagePickerController()
    
    /**
     the UIImage in pngData.
     */
    var imageData : Data? {
        didSet {
            if picker.sourceType == .camera {
                cameraButton.tintColor = .blue
            } else if picker.sourceType == .photoLibrary {
                albumButton.tintColor = .blue
            }
        }
    }
    /**
     Bein set from previous controller
     */
    var mode : Mode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        picker.delegate = self

        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        pickerSetup()
        handleLoginVsRegister()
        buttonConfig(mainButtonOutlet)
        testingUserSetup()
    }
    
    private func pickerSetup () {
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = true

        if mode == .login {            
            cameraButton.isHidden = true
            albumButton.isHidden = true
        }
    }
    
    private func handleLoginVsRegister () {
        
        mainButtonOutlet.setTitle(mode?.rawValue, for: .normal)
        
        if mode == .login {
            fullNameLabel.isHidden = true
            nameTextField.isHidden = true
        }
        if mode == .register {
            passwordTextField.returnKeyType = .next
        }
    }
    
    #warning("delete this after debug")
    private func testingUserSetup () {
        emailTextField.text = "test@gmail.com"
        passwordTextField.text = "123456"
        login.email = "test@gmail.com"
        login.password = "123456"
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            
        } else if textField == passwordTextField {
            
            if mode == .login { //if login, no userName button, resign and continue
                textField.resignFirstResponder()
                buttonPressed(mainButtonOutlet)
            } else if mode == .register { //if register, continue to username
                nameTextField.becomeFirstResponder()
            }
            
            
        } else if textField == nameTextField { //only when registering
            textField.resignFirstResponder()
            buttonPressed(mainButtonOutlet)
        }
        
        if textFieldIsValid(textField) {
            return true
        } else {
            return false
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         if textField == emailTextField {
             login.email = textField.text
         } else if textField == passwordTextField {
             login.password = textField.text
         } else if textField == nameTextField {
             login.userName = textField.text
         }
     }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        click(sender)
        
        view.endEditing(true)
                
        if mode == .register {
            guard textFieldIsValid(nameTextField) else {return}
            if let picErrorAlert = login.alertUserIfProfilePhotoIsNil() {
                present(picErrorAlert, animated: true)
                return
            }
            login.register()
        } else if mode == .login {
            login.signIn()
        } else {
            fatalError("Could not recognize sender title")
        }
        
    }
    
 
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        picker.sourceType = .camera
        present(picker, animated: true)
        
    }
    

    @IBAction func albumButtonPressed(_ sender: UIButton) {
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let editedPhoto = info[.editedImage] as? UIImage else {fatalError("could not create UIIMage from photo")}
        if let photoData = editedPhoto.pngData() {
            imageData = photoData
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(#function)
        
        picker.dismiss(animated: true)
    }
    
    
}



// MARK: - Global button setup & funcs

func buttonConfig (_ button:UIButton) {
    button.layer.shadowOffset = .init(width: 3, height: 3)
    button.layer.shadowColor = UIColor.darkGray.cgColor
    button.layer.shadowOpacity = 0.8
}

func click (_ button:UIButton) {
   let tap = UIImpactFeedbackGenerator(style: .heavy)
   tap.prepare()
   tap.impactOccurred()
   
   UIView.animate(withDuration: 0.2) {
       button.layer.shadowOffset = .init(width: 1, height: 1)
       button.layer.shadowColor = UIColor.darkGray.cgColor
       button.layer.shadowOpacity = 0.4
   } completion: { _ in
       UIView.animate(withDuration: 0.2) {
           button.layer.shadowOffset = .init(width: 3, height: 3)
           button.layer.shadowColor = UIColor.darkGray.cgColor
           button.layer.shadowOpacity = 0.8
       }
       
   }
   
    
    
    
    
   
}

