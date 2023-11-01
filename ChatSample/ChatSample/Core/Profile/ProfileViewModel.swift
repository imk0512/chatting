//
//  ProfileViewModel.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/30.
//

import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
  
  @Published var userId: String = ""
  @Published private(set) var user: DBUser? = nil
  @Published private(set) var userImage: UIImage? = nil
  
  func loadCurrentUser() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.userId = authDataResult.uid
    self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    if let auth = user, let path = user?.profileImagePath {
      let image = try? await ImageFileManager.shared.getImage(userId: auth.userId, path: path )
      self.userImage = image
    }
  }
}
