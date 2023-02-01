//
//  ChatViewController.swift
//  CoffeeFetch
//
//  Created by segev perets on 17/01/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import NaturalLanguage
import AVFoundation

class ChatViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    var player : AVAudioPlayer!
    /**
     MessageData = ["text":text, "time": Date(), "sender": email, "receiver" : otherEmail]
     */
    var messages = [[String:String]]() //being updated (only!) from listener
    
    
    var db = Firestore.firestore()
    
    /**
     ["email" : email, "username" : username]
     */
    var convoUser : [String:String]?
    
    var currentSpot : String? //from previous VC
    
    var myMessages : [[String:String]] {
        get {
            return messages.filter {$0["sender"] == FB.shared.currentUser!.email!}
        }
    }
    var hisMessages : [[String:String]] {
        get {
            if let convoUser {
                return messages.filter {$0["sender"] == convoUser["email"]}
            } else {fatalError("could not find convoUser, check prepare method at previous controller")}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        
        
        keyBoardSetup()
        
        if let convoUser {
            title = convoUser["username"]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotNewMessage(_:)), name: newMessageNotification, object: nil)
        
        sendButton.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FB.shared.newMessageListener(convoUser: convoUser!, spot: currentSpot!)

    }
    override func viewDidDisappear(_ animated: Bool) {
        FB.shared.listener?.remove()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if textIsValid(messageTextField) {
            FB.shared.sendMessage(messageTextField.text!, otherUser: convoUser!, spot: currentSpot!)
                        
            messageTextField.text = ""
            
            hideSendButton()
            
            playSendSound()
        }
    }
    
    // MARK: - Keyboard Managment
    
    private func keyBoardSetup () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue { //get keyBoard size
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let keyboardHeight = keyboardRectangle.height
            view.frame.origin.y = -keyboardHeight //view up by (keyboardHeight)
            tableView.contentInset = .init(top: keyboardHeight, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
        view.frame.origin.y =  0
        
    }
    
}
// MARK: - UITableView
extension ChatViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.isEmpty {
            return 0
        } else {
            return messages.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? ChatTableViewCell, let text = cell.mainText {
            if text.isRightToLeft {
                cell.semanticContentAttribute = .forceRightToLeft
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        guard !messages.isEmpty else {return cell}
        
        let messageSender = messages[indexPath.row]["sender"]!
        let currentUserEmail = FB.shared.currentUser!.email!
        let otherUserEmail = convoUser!["email"]!
        let messageText = messages[indexPath.row]["text"]!
        let messageTime = messages[indexPath.row]["time"]!
        

        let myMessage = messageSender == currentUserEmail
        let otherUserMessage = messageSender == otherUserEmail
        
        
        if myMessage {
            cell.sender = .currentUser
            cell.secondaryText = messageTime
            cell.mainText = messageText
        } else if otherUserMessage {
            cell.sender = .otherUser
            cell.secondaryText = messageTime
            cell.mainText = messageText
        }
        
        return cell
    }
    
    private func hideSendButton () {
        UIView.animate(withDuration: 0.2) {
            self.sendButton.alpha = 0
            self.sendButton.isHidden = true
        }
    }
    private func showSendButton () {
        UIView.animate(withDuration: 0.2) {
            self.sendButton.isHidden = false
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.sendButton.alpha = 1

            }
        }
    }
    
  
}

// MARK: - UITextField
extension ChatViewController : UITextFieldDelegate {
    
    private func textIsValid (_ textField:UITextField) -> Bool {
        if let text = textField.text, text != "" , text.contains(where: {$0 != Character(" ")}) {
            textField.placeholder = ""
            return true
        } else {
            showTextIsNotValidAnimation(textField)
            return false
        }
    }
    
    private func showTextIsNotValidAnimation (_ textField:UITextField) {
        print(#function)
        textField.placeholder = "write some stuff!"
        UIView.animate(withDuration: 0.2) {
            textField.backgroundColor = .systemPink
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                textField.backgroundColor = .white
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return true}
        let isEmpty = text.count <= 1 && string.isEmpty
        
        if !isEmpty {
            showSendButton()
        } else if isEmpty {
            hideSendButton()
        }
        return true
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed(sendButton)
        
        return true
        
    }
    
    // MARK: - Message handling
    
    @objc func gotNewMessage (_ notification:Notification) {
        
        let newMessage = notification.object as! [String:String]
        messages.append(newMessage)
        tableView.reloadData()
        scrollDown()
    }
    
    private func scrollDown () {
        if !messages.isEmpty {
            let lastRowIndex = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: lastRowIndex, at: .bottom, animated: true)
        }
    }
    
    private func playSendSound () {
        
        guard let url = Bundle.main.url(forResource: "sendSound", withExtension: "wav") else {fatalError()}
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.02
            player.play()
        } catch {
            print(error.localizedDescription)
        }

    }
    
    
    
}


extension String {
    var isRightToLeft: Bool {
        
        guard let language = NLLanguageRecognizer.dominantLanguage(for: self) else {
            return false
        }
        switch language {
        case .arabic, .hebrew, .persian, .urdu:
            return true
        default:
            return false
        }
    }
}
