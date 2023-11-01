//
//  CallRequestManager.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/11/01.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBCallRequest: Codable {
  let callUUID: String
  let callerId: String?
  let receiverId: String?
  let status: String? //  "pending", "accepted", "rejected", "ended"
  
  init(callerId: String,receiverId: String) {
    self.callUUID = UUID().uuidString
    self.callerId = callerId
    self.receiverId = receiverId
    self.status = "pending"
  }
  
  enum CodingKeys: String, CodingKey {
    case callUUID = "call_UUID"
    case callerId = "caller_id"
    case receiverId = "receiver_id"
    case status = "status"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.callUUID = try container.decode(String.self, forKey: .callUUID)
    self.callerId = try container.decodeIfPresent(String.self, forKey: .callerId)
    self.receiverId = try container.decodeIfPresent(String.self, forKey: .receiverId)
    self.status = try container.decodeIfPresent(String.self, forKey: .status)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.callUUID, forKey: .callUUID)
    try container.encodeIfPresent(self.callerId, forKey: .callerId)
    try container.encodeIfPresent(self.receiverId, forKey: .receiverId)
    try container.encodeIfPresent(self.status, forKey: .status)
  }
  
}
final class CallRequestManager {
  
  static let shared = CallRequestManager()
   private let db = Firestore.firestore()
   private let callRequestsCollection = "callRequests"
   
   private init() {}
     
  
  
  // 新しい通話リクエストをFirestoreに保存
  func createCallRequest(callerId: String, receiverId: String, completion: @escaping (Error?) -> Void) {
    let request = DBCallRequest(callerId: callerId, receiverId: receiverId)
    
    do {
      let _ = try db.collection(callRequestsCollection).addDocument(from: request) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  // 通話ステータスを更新
  func updateCallStatus(callUUID: String, status: String, completion: @escaping (Error?) -> Void) {
    let query = db.collection(callRequestsCollection).whereField("call_UUID", isEqualTo: callUUID)
    
    query.getDocuments { (snapshot, error) in
      guard let snapshot = snapshot, let document = snapshot.documents.first else {
        completion(error ?? NSError(domain: "No matching document", code: 404, userInfo: nil))
        return
      }
      
      document.reference.updateData(["status": status]) { updateError in
        completion(updateError)
      }
    }
  }
}
