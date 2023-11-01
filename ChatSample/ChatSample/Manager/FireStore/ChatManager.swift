
import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift
import PhotosUI
import UIKit

final class ChatManager {
    
    private let databaseReference: DatabaseReference = Database.database().reference().child("chat_messages")
    
    static let shared = ChatManager()
    private init() {}
    
    func observeMessages(matchId: String, completion: @escaping ([Massage]?) -> Void) {
        databaseReference.child(matchId)
            .queryOrdered(byChild: "timestamp")
            .observe(.value) { parentSnapshot in
                
                guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                    completion(nil)
                    return
                }
                
                let messages = children.compactMap({snapshot -> Massage? in
                    if let data = snapshot.value as? [String: Any],
                       let id = data["id"] as? String,
                       let senderId = data["senderId"] as? String,
                       let sender = data["sender"] as? String,
                       let type = data["type"] as? String,
                       let massageText = data["massageText"] as? String,
                       let imagePath = data["imagePath"] as? String,
                       let timestamp = data["timestamp"] as? Double
                    {
                        let timestampTimeInterval = TimeInterval(timestamp)
                        let timestampDate = Date(timeIntervalSince1970: timestampTimeInterval)
                        return Massage(id:id, senderId: senderId, sender: sender, type: type, massageText: massageText, imagePath: imagePath, timestamp: timestampDate)
                    } else {
                        return nil
                    }
                })
                completion(messages)
            }
    }
    
  func setTypingStatus(matchId: String, senderId: String, sender: String, isTyping: Bool, currentWaitingMessageId: String) async -> String {
      var updatedWaitingMessageId = currentWaitingMessageId
      
      if isTyping {
          updatedWaitingMessageId = UUID().uuidString
          let timestamp = Date().timeIntervalSince1970
          let newMassageData: [String: Any] = [
              "id": updatedWaitingMessageId,
              "senderId": senderId,
              "sender" : sender,
              "type": "message",
              "massageText": "...",
              "imagePath": "",
              "timestamp": timestamp
          ]
          try? await databaseReference.child(matchId).child(updatedWaitingMessageId).setValue(newMassageData)
      } else {
          if !updatedWaitingMessageId.isEmpty {
              try? await databaseReference.child(matchId).child(updatedWaitingMessageId).removeValue()
              updatedWaitingMessageId = ""
          }
      }
      
      return updatedWaitingMessageId
  }

    
    func sendMessage(matchId: String, senderId: String, sender: String, messageText: String) async {
        guard !messageText.isEmpty else { return }
        
        let id = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970
        let newMassageData: [String: Any] = [
            "id": id,
            "senderId": senderId,
            "sender" : sender,
            "type": "message",
            "massageText": messageText,
            "imagePath": "",
            "timestamp": timestamp
        ]
        try? await databaseReference.child(matchId).child(id).setValue(newMassageData)
    }
    
    func sendImageMessage(matchId: String, senderId: String, sender: String, image: UIImage) async throws -> String {
        let id = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970
        var imageData = ""
        
        let newMassageData: [String: Any] = [
            "id": id,
            "senderId": senderId,
            "sender" : sender,
            "type": "image",
            "massageText": "",
            "imagePath": "",
            "timestamp": timestamp
        ]

        try? await databaseReference.child(matchId).child(id).setValue(newMassageData)
        
        do {
            let (path, _) = try await ImageFileManager.shared.saveMassageImage(image: image, massageId: id)
            let url = try await ImageFileManager.shared.getUrlForImage(path: path)
            imageData = url.absoluteString
        } catch {
            try? await databaseReference.child(id).removeValue()
            throw error
        }
        
        let updatedData: [String: Any] = [
            "imagePath": imageData
        ]
        
        try? await databaseReference.child(matchId).child(id).updateChildValues(updatedData)
        return id
    }
}
