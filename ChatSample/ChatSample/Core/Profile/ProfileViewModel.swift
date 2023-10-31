//
//  ProfileViewModel.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/30.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
  
  @Published private(set) var user: DBUser? = nil
  
  func loadCurrentUser() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    if let auth = user, let path = user?.profileImagePath {
      let image = try? await ImageFileManager.shared.getImage(userId: auth.userId, path: path )
      self.user?.profileImage = image
    }
  }
}
