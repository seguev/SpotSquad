//
//  FirebaseUser.swift
//  CoffeeFetch
//
//  Created by segev perets on 12/01/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

let newMessageNotification = Notification.Name("newMessage")
let gotUsersNotification = Notification.Name(UUID().uuidString)

struct FB {
    
    static var shared = FB()
    
    let db = Firestore.firestore()
    
    
    var currentUser : User?
    var listener : ListenerRegistration?
    var storage = Storage.storage().reference()
    
    func logout () {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    /**
     Add a new spot to Cafe collection at firebase.
     - checks if each spots exists in database
     - if so, calls updateData
     - if not, calls setData(merge=true)
     - currentUser takes time to update and can be nil for in the beggining. so func calls itself if nil, till updates.
     */
    func addCafeToFBCollection (from spots:[String]) {
        
        guard let user = Auth.auth().currentUser else {
            addCafeToFBCollection(from: spots)
            return
        }
        for spot in spots {
            
            let spotDocument = db.collection("cafe").document(spot)
            spotDocument.getDocument { document, error in
                
                if let document = document, document.exists {
                    print("found \(spot), adding current user!")
                    db.collection("cafe").document(spot).updateData(["UIDs" : FieldValue.arrayUnion([user.uid])])
                } else {
                    print("could not find \(spot), adding it now.")
                    db.collection("cafe").document(spot).setData(["UIDs" : FieldValue.arrayUnion([user.uid])], merge: true)
                    
                }
                
            }
            
            
        }
    }    
    
    /**
     Fetch all spot's UIDs of a spot and call getUserNamesFromUIDs() for each.
     - search the "cafe" collection for the specific "Spot"
     - if exists, call getUserNamesFromUIDs() for every UID.
     - each user = ["username" : username, "email":email,"uid":uid]
     - filters current user from users found
     */
    func fetchSpotUIDs (_ spot:String) async {
        print(#function)
                
        do {
            let document = try await db.collection("cafe").document(spot).getDocument()
            if document.exists {
                guard let UIDs = document.get("UIDs") as? [String] else {return}
                var users = [[String:String]]()
                for uid in UIDs {
                    let newUserFound = await getUserInfoFromUid(uid)
                    users.append(newUserFound)
                    
                }
                users.removeAll { $0["uid"] == currentUser!.uid }
                NotificationCenter.default.post(name: gotUsersNotification, object: users)
            }
        } catch {
            print(error)
        }
    }
    
    /**
     This func runs for each user in chosen spot
     */
    private func getUserInfoFromUid (_ uid:String) async -> [String:String] {
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            if snapshot.exists {
                let userName = snapshot.get("username") as! String
                let email = snapshot.get("email") as! String
                let userUid = uid
                
                return ["username":userName,
                        "email":email,
                        "uid":userUid]
            } else {
                return [:]
            }
        } catch {
            print("error while fetcing userInfo : \(error)")
            return [:]
        }
    }
    
    func createHash(currentUserEmail: String, otherUserEmail: String) -> String {
        let combined = (currentUserEmail+otherUserEmail).sorted()
        var fixed = Array(combined[0...combined.count-1]).map{String($0)}
        fixed.removeAll { $0 == "@" || $0 == "." }
        return fixed.joined()
    }
    
    
    // MARK: - User Image Request
    
    /**
     Use this func to fetch other users, using their uid .
     */
    func fetchUserPhoto (uid:String, complition : @escaping (UIImage) -> Void)  {
        print(#function)
        let storagePath = storage.child("profileImages/\(uid)/photo.jpeg")
        
        storagePath.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error {
                print("Errors while fetching user photo \(error)")
            } else if let data {
                guard let image = UIImage(data: data) else {fatalError("could not convert data to UIImage")}
                print("updating photo for mr. \(uid)")
                complition(image)
            } else {
                fatalError("no errors & no data?")
            }
        }
        
    }
    
    
    // MARK: - Chat
    /**
     MessageData = ["text":text, "time": Date(), "sender": email, "receiver" : otherEmail]
     */
    func sendMessage (_ text:String, otherUser:[String:String], spot:String) {
        
        //["message" : message, "date" : time, "sender" : email, "receiver" : receiver]
        
        if let currentUser = currentUser, let email = currentUser.email, let otherEmail = otherUser["email"]  {
            
            let hash = createHash(currentUserEmail: email, otherUserEmail: otherEmail)
            
            db.collection("messages").document(spot).collection(hash).addDocument(data: ["text":text, "time": Date(), "sender": email, "receiver" : otherEmail])
            
        }
    }
    
    /**
     MessageData = ["text":text, "time": String, "sender": String, "receiver" : String]
     */
    mutating func newMessageListener (convoUser:[String:String],spot:String) {
        print("Listening to \(currentUser!.displayName!)'s and \(convoUser["username"]!)'s convo at \(spot) cafe")
        
        if let currentMail = currentUser?.email, let otherEmail = convoUser["email"] {
            let hash = createHash(currentUserEmail: currentMail, otherUserEmail: otherEmail)
            
        
            listener = db.collection("messages").document(spot).collection(hash).order(by: "time").addSnapshotListener { snapshot, error in
                if let error {
                    print(error)
                } else if let snapshot, !snapshot.isEmpty {
                    for doc in snapshot.documentChanges {
                        if doc.type == .added { //old message = added, new is added&modified
                            //printMessageType(doc.type)
                            
                            var newMessage = [String:String]()
                            
                            let data = doc.document.data()
                            let timeStamp = data["time"] as! Timestamp
                            let DF = DateFormatter()
                            DF.dateFormat = "HH:mm a"
                            let time = timeStamp.dateValue()
                            let formattedTime = DF.string(from: time)
                            
                            if let text = data["text"] as? String, let sender = data["sender"] as? String, let receiver = data["receiver"] as? String {
                                
                                newMessage["text"] = text
                                newMessage["time"] = formattedTime
                                newMessage["sender"] = sender
                                newMessage["receiver"] = receiver
                                
                                NotificationCenter.default.post(name: newMessageNotification, object: newMessage)
                            } else {
                                print("found unknown key in data()")
                                return
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func printMessageType(_ type:DocumentChangeType) {
        switch type {
        case .added:
            print("added")
        case .modified:
            print("modified")
        case .removed:
            print("removed")
        }
    }
    
    func changeUserName (to newUserName:String, complition: @escaping ()->Void) {
        
        let changeRequest = currentUser!.createProfileChangeRequest()
        changeRequest.displayName = newUserName
        
        changeRequest.commitChanges { error in
            if error == nil {
                print("Successfuly changed userName to \(newUserName).")
                
                db.collection("users").document(currentUser!.uid).updateData(["username":newUserName])
                    
                complition()
            }
        }
    }
    
}
