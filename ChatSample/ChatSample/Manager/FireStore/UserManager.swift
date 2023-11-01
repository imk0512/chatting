//
//  UserManager.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable {
  let userId: String
  let email: String?
  let name: String?
  let sex: String?
  let birth: String?
  let photoUrl: String?
  let createdAt: Date?
  let profileImagePath: String?
  let profileImageUrl: String?
  
  init(auth: AuthDataResultModel) {
    self.userId = auth.uid
    self.email = auth.email ?? ""
    self.name = ""
    self.sex = ""
    self.birth = ""
    self.photoUrl = auth.photoUrl ?? ""
    self.createdAt = Date()
    self.profileImagePath = ""
    self.profileImageUrl = ""
  }
  
  init(auth: AuthDataResultModel,name: String, sex:String, birth: String, profileImagePath: String,profileImageUrl: String) {
    self.userId = auth.uid
    self.email = auth.email ?? ""
    self.name = name
    self.sex = sex
    self.birth = birth
    self.photoUrl = auth.photoUrl ?? ""
    self.createdAt = Date()
    self.profileImagePath = profileImagePath
    self.profileImageUrl = profileImageUrl
  }
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case email = "email"
    case name = "name"
    case sex = "sex"
    case birth = "birth"
    case photoUrl = "photo_url"
    case createdAt = "created_at"
    case profileImagePath = "profile_image_path"
    case profileImageUrl = "profile_image_url"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
      self.userId = try container.decode(String.self, forKey: .userId)
      self.email = try container.decodeIfPresent(String.self, forKey: .email)
      self.name = try container.decodeIfPresent(String.self, forKey: .name)
      self.sex = try container.decodeIfPresent(String.self, forKey: .sex)
      self.birth = try container.decodeIfPresent(String.self, forKey: .birth)
      self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
      self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
      self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
      self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.userId, forKey: .userId)
    try container.encodeIfPresent(self.email, forKey: .email)
    try container.encodeIfPresent(self.name, forKey: .name)
    try container.encodeIfPresent(self.sex, forKey: .sex)
    try container.encodeIfPresent(self.birth, forKey: .birth)
    try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
    try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
    try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
    try container.encodeIfPresent(self.profileImageUrl, forKey: .profileImageUrl)
  }
  
}


final class UserManager {
  
  static let shared = UserManager()
  private init() {}
  
  private let usercCollection = Firestore.firestore().collection("users")
  
  private func userDocument(userId: String) -> DocumentReference {
    usercCollection.document(userId)
  }
  
  
  func createNewUser(user: DBUser) async throws {
    try userDocument(userId: user.userId).setData(from: user , merge:false)
  }
  
  func getUser(userId: String) async throws -> DBUser? {
    do {
      let document = try await userDocument(userId: userId).getDocument()
      
      if document.exists {
        return try document.data(as: DBUser.self)
      } else {
        return nil
      }
    } catch {
      throw error
    }
  }
  
  
}
