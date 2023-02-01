//
//  SpotCollectionViewController.swift
//  CoffeeFetch
//
//  Created by segev perets on 06/01/2023.
//



import UIKit
import MapKit

let updateUINotification = Notification.Name("updateUI")

private let reuseIdentifier = "SpotCollectionViewCell"

class SpotCollectionViewController: UICollectionViewController {

    @IBOutlet var popUp: UIView!
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!    
       
    var selectedSpot : String?
    
    var spotsArray: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: updateUINotification, object: nil)
                
//        Task { await StorageManager.shared.saveTenFakeVisits() }
        
        initialConfig()
        
        spotsArray = StorageManager.shared.loadSortedSpotsStrings()
        
        FB.shared.addCafeToFBCollection(from: spotsArray) ;#warning("check")

//        NotificationCenter.default.post(name: updateUINotification, object: nil)
        
        
//        titleButton.setTitle(FB.shared.currentUser!.displayName!, for: .normal)
        
        
        
        updateUI()
        
        StorageManager.shared.printAllSavesSpots()
        
        if spotsArray.isEmpty {showNoSpotsPopUp()}
    }

    private func showNoSpotsPopUp () {
        popUp.alpha = 0
        popUpLabel.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.popUp.frame = .init(x: self.view.center.x, y: 50, width: 200, height: 150)
            self.popUp.center = .init(x: self.view.center.x, y: self.view.center.y - 100 )
            self.popUp.backgroundColor = .systemGray6
            self.popUpLabel.numberOfLines = 0
            self.popUpLabel.text = "You need to visit more places! make sure you share your location Always or When using the app."
            self.popUpLabel.textAlignment = .center
            self.popUp.layer.cornerRadius = 10
            self.popUp.layer.shadowColor = UIColor.black.cgColor
            self.popUp.layer.shadowRadius = 20
            self.popUp.layer.shadowOffset = .init(width: 4, height: 4)
            self.popUp.layer.shadowOpacity = 0.5
            let blur = UIVisualEffectView(frame: self.view.frame)
            blur.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            self.popUp.alpha = 1
            self.popUpLabel.alpha = 1
            self.view.addSubview(blur)
            self.view.addSubview(self.popUp)
        }
    }

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you want to log out?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            FB.shared.logout()
            alert.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true)
    }
  

    @IBAction func userNamePressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Change username", style: .default, handler: { _ in
            alert.dismiss(animated: true)
            self.changeUsername()
        }))
        present(alert, animated: true)
        titleButton.isSelected = false
    }
    
    private func changeUsername () {
        var textField = UITextField()
//        let isValid = textField.text?.contains { !CharacterSet.alphanumerics.contains($0.unicodeScalars.first!) }
        let alert = UIAlertController(title: "Write a new username", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addTextField { alertTextField in
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let text = textField.text, text.contains(where: { $0 != " " }){
                
                FB.shared.changeUserName(to: text, complition: self.updateUI)
                
            }
        }))
        present(alert, animated: true)
    }
    
    private func initialConfig () {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 150, height: 150)
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout

    }
    
    /**
     Being called from LoginModel if registering.
     - does NOT being called from signIn()
     */
    private func updateUI() {
        print(#function)
        
        if let userName = FB.shared.currentUser?.displayName {
            print("setting username as \(userName)")
            titleButton.setTitle(userName, for: .normal)
            navigationItem.backButtonTitle = userName
        } else {
            print("could not find username")
        }

        activityIndicator.stopAnimating()
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegate

extension SpotCollectionViewController {
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedSpot = spotsArray[indexPath.item] //set selected spot variable

        Task {
            await FB.shared.fetchSpotUIDs(selectedSpot!)
        }
                
        
        (collectionView.cellForItem(at: indexPath) as! SpotCollectionViewCell).click()
        performSegue(withIdentifier: "toUsers", sender: self) //segue to next controller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destiationVC = segue.destination as! UsersCollectionViewController
        
        destiationVC.currentSpot = selectedSpot //update next controller global variable for the title
    }
    
    
}



// MARK: - UICollectionViewDataSource
extension SpotCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard !spotsArray.isEmpty else {return 0} //if no visits yet or until reload .
        
        return spotsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SpotCollectionViewCell
//        cell.layer.cornerRadius = cell.bounds.height/2
//         cell.clipsToBounds = true
        
        
        
        if spotsArray.isEmpty {
            cell.spotConfig("No Spots Yet", index: 0)
            return cell
        }

        cell.spotConfig(spotsArray[indexPath.item], index: indexPath.item)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SpotCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 100, bottom: 20, right: 100)
    }
    
    
    
    
}

