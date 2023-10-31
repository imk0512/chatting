//
//  SignInGoogleHelper.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


struct GoogleSignInResultModel {
  let idToken:String
  let accessToken: String
  let email: String?
  
}

final class SignInGoogleHelper {
  
  @MainActor
  func signIn() async throws -> GoogleSignInResultModel{
    guard let topVC = Utilties.shared.topViewController() else {
      throw URLError(.cannotFindHost)
    }
            
    let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
    
    guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
      throw URLError(.badServerResponse)
    }
    
    let accessToken = gidSignInResult.user.accessToken.tokenString
    let email = gidSignInResult.user.profile?.email
    
    let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken,email: email)
    
    return tokens
  }
  
}
