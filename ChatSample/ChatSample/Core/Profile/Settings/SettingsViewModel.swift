//
//  SettingsViewModel.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
  
  
  func signOut() throws{
    try AuthenticationManager.shared.signOut()
  }
  
  func resetPassword() async throws {
    let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
    
    guard let email = authUser.email else {
      throw URLError(.fileDoesNotExist)
    }
    
    try await AuthenticationManager.shared.resetPassword(email:email)
    
  }
  
  func updateEmail () async throws {
    let email = "hello123@gmail.com"
    try await AuthenticationManager.shared.updateEmail(email: email)
  }
  
  func updatePassword () async throws {
    let passowrd = "43214321"
    try await AuthenticationManager.shared.updatePassword(password: passowrd)
  }
  
  
}
