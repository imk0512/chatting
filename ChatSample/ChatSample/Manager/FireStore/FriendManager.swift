
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBFriend: Codable, Identifiable {
  let id: String
  let userId: String
  let name: String?
  let matchId: String?
  let photoUrl: String?
  let createdAt: Date?
  let profileImagePath: String?
  let profileImageUrl: String?
  
  
  
  init(friend: DBUser, matchId: String) {
    self.id = UUID().uuidString
    self.userId = friend.userId
    self.name = friend.name
    self.matchId = matchId
    self.photoUrl = friend.photoUrl
    self.createdAt = Date()
    self.profileImagePath = friend.profileImagePath
    self.profileImageUrl = friend.profileImageUrl
  }
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case userId = "user_id"
    case name = "name"
    case matchId = "match_id"
    case photoUrl = "photo_url"
    case createdAt = "created_at"
    case profileImagePath = "profile_image_path"
    case profileImageUrl = "profile_image_url"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.userId = try container.decode(String.self, forKey: .userId)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.matchId = try container.decodeIfPresent(String.self, forKey: .matchId)
    self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
    self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.userId, forKey: .userId)
    try container.encodeIfPresent(self.name, forKey: .name)
    try container.encodeIfPresent(self.matchId, forKey: .matchId)
    try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
    try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
    try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
    try container.encodeIfPresent(self.profileImageUrl, forKey: .profileImageUrl)
  }
  
}


final class FriendManager {
  
  static let shared = FriendManager()
  private init() {}
  
  private let friendsCollection = Firestore.firestore().collection("friends")
  
  private func friendDocument(userId: String) -> DocumentReference {
    friendsCollection.document(userId)
  }
  
  private func friendDocumentCollection(userId: String) -> CollectionReference {
    friendsCollection.document(userId).collection("userFriends")
  }
  
  
  func createNewFriend(userId: String, friend: DBFriend) async throws {
    do {
      let docRef = friendDocumentCollection(userId: userId).document(friend.userId)
      try await docRef.setData(from: friend, merge: false)
    } catch {
      throw error
    }
  }
  
  func getFriends(userId: String) async throws -> [DBFriend]? {
    do {
      let querySnapshot = try await friendDocumentCollection(userId: userId).getDocuments()
      let friends: [DBFriend] = querySnapshot.documents.compactMap { document in
        return try! document.data(as: DBFriend.self)
      }
      
      return friends.isEmpty ? nil : friends
    } catch {
      throw error
    }
  }
  
  
  
}
