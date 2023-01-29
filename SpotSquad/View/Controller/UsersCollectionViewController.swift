//
//  UsersCollectionViewController.swift
//  CoffeeFetch
//
//  Created by segev perets on 13/01/2023.
//

import UIKit

private let reuseIdentifier = "Cell"

class UsersCollectionViewController: UICollectionViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /**
     ["username" : username, "email":email, "uid":userUid]
     */
    var users : [[String:String]]? //being set from gotUsers()
    
    var selectedUser : [String:String]?
    
    var currentSpot : String? //being set from previous VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotUsers(_:)), name: gotUsersNotification, object: nil)
        
        collectionViewSetup()
        
        title = "\(currentSpot!) Squad"
    }

    func collectionViewSetup () {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 170, height: 190)
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        
    }
    
    /**
     Called from previous controller and sets global users variable.
     */
    @objc func gotUsers (_ notification:Notification) {
        let users = notification.object as! [[String:String]]
        
   
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
            self.users = users
        }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        users?.count ?? 0
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserCollectionViewCell
        guard let userName = users![indexPath.row]["username"] else {fatalError("could not get username from dictionary")}
        guard let userUid = users![indexPath.row]["uid"] else {fatalError("could not get userUid from dictionary")}
        
        print(indexPath.row)
        print(users![indexPath.row])
        
        cell.config(userName)
        FB.shared.fetchUserPhoto(uid: userUid) { image in
            cell.updateImage(image)
            print("photo for \(userUid) has been updated")
        }
        return cell
    }
    
    // MARK: - Cell Selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let users {
            selectedUser = users[indexPath.item]
            
            performSegue(withIdentifier: "toChat", sender: self)
        } else {
            fatalError("no users!@#$%")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedUser, let currentSpot = currentSpot {
            let destinationVC = segue.destination as! ChatViewController
            destinationVC.convoUser = selectedUser
            destinationVC.currentSpot = currentSpot
            
        }
    }
    
    
}
extension UsersCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 100, bottom: 20, right: 100)
    }
    
    
    
    
}

