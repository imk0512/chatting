

import Foundation
import UIKit


@MainActor
final class MatchingViewModel: ObservableObject {
  
  @Published private(set) var matching: DBMatches? = nil
  @Published private(set) var userId: String = ""
  @Published private(set) var matchingId: String? = nil
  @Published private(set) var counterpartUser: DBUser? =  nil
  @Published private(set) var counterpartImage: UIImage? = nil
  
  func isWaiting() -> Bool{
    guard let matching = matching else {
      print("No matching")
      return false
    }
    var bool = false
    if let user1 = matching.user1 as? String, user1 == userId {
      bool = matching.user1Consent
    } else if let user2 = matching.user2 as? String, user2 == userId {
      bool = matching.user2Consent
    }
    return bool
  }
  
  func initCounterpartUser() {
    self.counterpartUser = nil
    self.counterpartImage = nil
  }
  
  func loadCurrentUser() async throws {
    let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
    self.userId = authUser.uid
  }
  
  func searchMatching() async throws {
    print("searchMatching")
    let matchingId =  try await MatchingManager.shared.findMatching()
    self.matchingId = matchingId
  }
  
  func createMatching() async throws {
    print("createMatching")
    let matchingNewData = DBMatches(owner: userId)
    let matchingId = try await MatchingManager.shared.crateMatching(mathcing: matchingNewData)
    self.matchingId = matchingId
  }
  
  func getMatching(matchingId: String) async throws {
      MatchingManager.shared.getMatching(matchingId: matchingId) { updatedMatching in
          self.matching = updatedMatching
      }
  }
  
  func updateMatching() async throws {
    try await MatchingManager.shared.updateMatchingStatusIsPending(userId:userId, matchingId: matchingId ?? "")
  }
  
  func updateMatchingConsent() async throws {
    guard let matching = matching else {
      print("No matching")
      return
    }
    if let user1 = matching.user1 as? String, user1 == userId {
      let status = matching.user2Consent ? "chatting" : "pending"
      try await MatchingManager.shared.updateMatchingUser1Consent(matchingId: matching.matchingId,matchingStatus: status)
    } else if let user2 = matching.user2 as? String, user2 == userId {
      let status = matching.user1Consent ? "chatting" : "pending"
      try await MatchingManager.shared.updateMatchingUser2Consent(matchingId: matching.matchingId,matchingStatus: status)
    }
  }
  
  func updateMatchingCancel() async throws {
    guard let matching = matching else {
      print("No matching")
      return
    }
    guard let user2 = matching.user2 else {
      print("No user2")
      return
    }
    if let user1 = matching.user1 as? String, user1 == userId {
      let status = matching.user2Consent ? "chatting" : "pending"
      try await MatchingManager.shared.updateMatchingUser1Cancel(matchingId: matching.matchingId,userId: user2)
    } else if let user2 = matching.user2 as? String, user2 == userId {
      let status = matching.user1Consent ? "chatting" : "pending"
      try await MatchingManager.shared.updateMatchingUser2Cancel(matchingId: matching.matchingId)
    }
  }
  
  func getMatchingUser() async throws {
    guard let matching = matching else {
      print("No matching")
      return
    }
    print("getMatchingUser")
    
    var counterpartId: String = ""
    if let user1 = matching.user1 as? String, user1 != userId {
      counterpartId = user1
    } else if let user2 = matching.user2 as? String, user2 != userId {
      counterpartId = user2
    }
    self.counterpartUser = try await UserManager.shared.getUser(userId: counterpartId)

    if let path = counterpartUser?.profileImagePath{
      let image = try? await ImageFileManager.shared.getImage(userId:counterpartId,path: path)
      self.counterpartImage = image
    }
  }
  
  func matchingCancel() async throws {
    try await MatchingManager.shared.deleteMatching(matchingId: matchingId!)
  }
  
  func createFriend () async throws {
    
    guard let matchingId ,let counterpart = counterpartUser else {
      print("createFriend error")
      return
    }
    let friend = DBFriend(friend: counterpart,matchId: matchingId)
    try await FriendManager.shared.createNewFriend(userId: userId, friend:friend)
    
  }
  
}
