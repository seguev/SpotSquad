//
//  UserViewController.swift
//  CoffeeFetch
//
//  Created by segev perets on 11/01/2023.
//

import UIKit

class UserViewController: UIViewController, UINavigationBarDelegate {
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonConfig(loginButton)
        buttonConfig(signupButton)
        
    }
    enum SegueIdentifier : String {
        case signUp = "signUp"
        case signIn = "signIn"
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        click(sender)
        performSegue(withIdentifier: SegueIdentifier.signUp.rawValue, sender: self)
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        click(sender)
        performSegue(withIdentifier: SegueIdentifier.signIn.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! LoginViewController
        
        if segue.identifier == SegueIdentifier.signUp.rawValue {
            destinationVC.mode = .register
            
        } else if segue.identifier == SegueIdentifier.signIn.rawValue {
            destinationVC.mode = .login
           
        }
    }
    

}
