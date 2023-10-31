//
//  AuthenticationViewModel.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
  
  func signInGoogle() async throws -> AuthDataResultModel{
    let helper = SignInGoogleHelper()
    let tokens = try await helper.signIn()
    let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    return authDataResult
  }
  
  func checkExist(userId: String) async throws -> Bool{
    do {
      let user = try await UserManager.shared.getUser(userId: userId)
      if user == nil {
        return true
      } else {
        return false
      }
    } catch {
      throw error
    }
  }
}
