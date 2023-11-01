//
//  MatchManager.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/29.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift


struct DBMatches: Codable {
  let matchingId: String
  let user1: String?
  let user2: String?
  let user1Consent: Bool
  let user2Consent: Bool
  // マッチングステータス
  // - "waiting": 待機中のユーザー
  // - "pending": チャットが成立し、チャットが開始されていない
  // - "chatting": チャットが進行中
  // - "ended": マッチングが終了し、チャットが終了
  let status: String?
  let createdAt: Date?
  let deletedAt: Date?
  
  init(owner: String) {
    self.matchingId = UUID().uuidString
    self.user1 = owner
    self.user2 = ""
    self.user1Consent = false
    self.user2Consent = false
    self.status = "waiting"
    self.createdAt = Date()
    self.deletedAt = nil
  }
  
  
  enum CodingKeys: String, CodingKey {
    case matchingId = "matching_id"
    case user1 = "user1"
    case user2 = "user2"
    case user1Consent = "user1_consent"
    case user2Consent = "user2_consent"
    case status = "status"
    case createdAt = "created_at"
    case deletedAt = "deleted_at"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.matchingId = try container.decode(String.self, forKey: .matchingId)
    self.user1 = try container.decodeIfPresent(String.self, forKey: .user1)
    self.user2 = try container.decodeIfPresent(String.self, forKey: .user2)
    self.user1Consent = try container.decode(Bool.self, forKey: .user1Consent)
    self.user2Consent = try container.decode(Bool.self, forKey: .user2Consent)
    self.status = try container.decodeIfPresent(String.self, forKey: .status)
    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.matchingId, forKey: .matchingId)
    try container.encodeIfPresent(self.user1, forKey: .user1)
    try container.encodeIfPresent(self.user2, forKey: .user2)
    try container.encodeIfPresent(self.user1Consent, forKey: .user1Consent)
    try container.encodeIfPresent(self.user2Consent, forKey: .user2Consent)
    try container.encodeIfPresent(self.status, forKey: .status)
    try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
    try container.encodeIfPresent(self.deletedAt, forKey: .deletedAt)
  }
  
  
}

final class MatchingManager {
  static let shared = MatchingManager()
  private init() {}
  
  private(set) var matchingStatus: String = ""
  
  private let matchesCollection = Firestore.firestore().collection("matches")
  
  private func matchingDocument(matchingId: String) -> DocumentReference {
    matchesCollection.document(matchingId)
  }
  
  func findMatching() async throws -> String? {
    let query = matchesCollection
      .whereField("status", isEqualTo: "waiting")
      .limit(to: 1)
    
    do {
      let querySnapshot = try await query.getDocuments()
      
      if let document = querySnapshot.documents.first,
         let matching = try document.data(as: DBMatches?.self) {
        
        return matching.matchingId
      } else {
        
        return nil
      }
    } catch {
      throw error
    }
  }

  
  func getMatching(matchingId: String, completion: @escaping (DBMatches?) -> Void) {
    print("getMatching")
    matchesCollection
      .whereField("matching_id", isEqualTo: matchingId)
      .addSnapshotListener { querySnapshot, error in
        if let error = error {
          print("Error: \(error.localizedDescription)")
          completion(nil)
          return
        }
      
        guard let documents = querySnapshot?.documents else {
          print("No Docments")
          completion(nil)
          return
        }
        for document in documents {
          if let matching = try? document.data(as: DBMatches.self) {
            completion(matching)
          } else {

            completion(nil)
          }
          
        }
      }
  }
  
  
  func crateMatching(mathcing: DBMatches) async throws -> String {
    try matchingDocument(matchingId: mathcing.matchingId).setData(from: mathcing, merge:false)
    return mathcing.matchingId
  }
  
  func updateMatchingStatusIsPending(userId:String ,matchingId: String) async throws {
    let data: [String: Any] = [
      "user2": userId,
      "status": "pending"
    ]
    try await matchingDocument(matchingId: matchingId).updateData(data)
  }
  
  func updateMatchingUser1Consent(matchingId: String,matchingStatus: String) async throws {
    let data: [String: Any] = [
      "user1_consent": true,
      "status": matchingStatus
    ]
    try await matchingDocument(matchingId: matchingId).updateData(data)
  }
  
  func updateMatchingUser2Consent(matchingId: String,matchingStatus: String) async throws {
    let data: [String: Any] = [
      "user2_consent": true,
      "status": matchingStatus
    ]
    try await matchingDocument(matchingId: matchingId).updateData(data)
  }
  
  func updateMatchingUser1Cancel(matchingId: String,userId: String) async throws {
    let data: [String: Any] = [
      "user1": userId,
      "user2": "",
      "user1_consent": false,
      "user2_consent": false,
      "status": "waiting"
    ]
    try await matchingDocument(matchingId: matchingId).updateData(data)
  }
  
  func updateMatchingUser2Cancel(matchingId: String) async throws {
    let data: [String: Any] = [
      "user2": "",
      "user1_consent": false,
      "user2_consent": false,
      "status": "waiting"
    ]
    try await matchingDocument(matchingId: matchingId).updateData(data)
  }
  
  func deleteMatching(matchingId: String) async throws {
    try await matchingDocument(matchingId: matchingId).delete()
  }
  
}
