import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift
import PhotosUI

struct Massage: Identifiable, Equatable {
  var id: String
  var senderId: String
  var sender: String
  var massageText: String
  var timestamp: Date?
}


@MainActor
class ChatRoomViewModel: ObservableObject {
  private var databaseReference: DatabaseReference
  private var matchId: String = ""
  private var sender: String = ""
  
  @Published  var senderId: String = ""
  @Published private(set) var user: DBUser? = nil
  @Published var massage: Massage? = nil
  @Published var massageList: [Massage] = []
  
  init(matchId: String) {
    self.databaseReference = Database.database().reference().child("chat_messages").child(matchId)
    
    self.matchId = matchId
    
    
  }
  
  func loadCurrentUser() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    if let auth = user, let path = user?.profileImagePath {
      let image = try? await ImageFileManager.shared.getImage(userId: auth.userId, path: path )
      self.user?.profileImage = image
    }
    
    guard let userId = self.user?.userId, let  userName = self.user?.name else {
      return
    }
    
    self.senderId = userId
    self.sender = userName
  }
  
  
  func observerListObject() {
    databaseReference.observe(.value) { parentSnapshot in
      
      guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
        return
      }
      
      self.massageList = children.compactMap({snapshot in
        if let data = snapshot.value as? [String: Any],
           let id = data["id"] as? String,
           let senderId = data["senderId"] as? String,
           let sender = data["sender"] as? String,
           let massageText = data["massageText"] as? String,
           let timestamp = data["timestamp"] as? Double
        {
          let timestampTimeInterval = TimeInterval(timestamp) // Unixエポック秒に変換
          let timestampDate = Date(timeIntervalSince1970: timestampTimeInterval) // Date型に変換
          return Massage(id:id,senderId: senderId, sender: sender,massageText: massageText,timestamp: timestampDate)
          print("Received message: \(self.massage)")
        } else {
          // データが存在しない場合の処理
          print("No message data found or data is incomplete.")
          return nil
        }
        
      })
      
    }
  }
  
  func sendMassage(massageText: String) {
    let id = UUID().uuidString
    let timestamp = Date().timeIntervalSince1970
    let newMassageData: [String: Any] = [
      "id": id,
      "senderId": senderId,
      "sender" : sender,
      "massageText": massageText,
      "timestamp": timestamp
    ]
    
    // 新しいメッセージを送信
    databaseReference.childByAutoId().setValue(newMassageData)
  }
  
}
