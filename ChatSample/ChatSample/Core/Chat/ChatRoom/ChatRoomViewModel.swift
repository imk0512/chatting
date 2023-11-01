import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift
import PhotosUI
import UIKit

struct Massage: Identifiable, Equatable {
    var id: String
    var senderId: String
    var sender: String
    var type: String
    var massageText: String
    var imagePath: String
    var timestamp: Date?
}

@MainActor
class ChatRoomViewModel: ObservableObject {
    private var matchId: String = ""
    private var friendId: String = ""
    private var sender: String = ""
    private var waitingMessageId: String = ""
    
    @Published var senderId: String = ""
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var friend: DBUser? = nil
    @Published private(set) var friendImage: UIImage? = nil
    @Published var massage: Massage? = nil
    @Published var massageList: [Massage] = []
    @Published private(set) var userImage: UIImage? = nil
    
    init(matchId: String, friendId: String) {
        self.matchId = matchId
        self.friendId = friendId
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        if let auth = user, let path = user?.profileImagePath {
            let image = try? await ImageFileManager.shared.getImage(userId: auth.userId, path: path)
            self.userImage = image
        }
        
        guard let userId = self.user?.userId, let userName = self.user?.name else {
            return
        }
        
        self.senderId = userId
        self.sender = userName
    }
    
    func loadFriend() async throws {
        self.friend = try await UserManager.shared.getUser(userId: friendId)
        if let auth = friend, let path = friend?.profileImagePath {
            let image = try? await ImageFileManager.shared.getImage(userId: friendId, path: path)
            self.friendImage = image
        }
    }
    
    func observerListObject() {
        ChatManager.shared.observeMessages(matchId: matchId) { messages in
            if let messages = messages {
                self.massageList = messages
            }
        }
    }
    
    func setTypingStatus(isTyping: Bool) async {
        waitingMessageId = await ChatManager.shared.setTypingStatus(matchId: matchId, senderId: senderId, sender: sender, isTyping: isTyping, currentWaitingMessageId: waitingMessageId)
    }
    
    func sendTextMessage(massageText: String) async {
        await ChatManager.shared.sendMessage(matchId: matchId, senderId: senderId, sender: sender, messageText: massageText)
    }
    
    func sendImageMessage(image: UIImage) async {
        do {
            _ = try await ChatManager.shared.sendImageMessage(matchId: matchId, senderId: senderId, sender: sender, image: image)
        } catch {
            print("Failed to send image message: \(error)")
        }
    }
}
