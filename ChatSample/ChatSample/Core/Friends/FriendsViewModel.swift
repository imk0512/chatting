import Foundation

@MainActor
final class FriendsViewModel: ObservableObject {
  @Published var friends: [DBFriend]? = nil
  @Published var userId: String = ""

  func loadFriends() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.userId = authDataResult.uid
    self.friends =  try await FriendManager.shared.getFriends(userId: userId)
  }
}
