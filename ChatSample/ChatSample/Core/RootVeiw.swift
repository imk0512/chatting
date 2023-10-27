//
//  RootVeiw.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI


struct RootVeiw: View {
  
  @State private var showSignInVeiw: Bool = false
  @State private var isNotRegistered: Bool = false
  @State private var isLoading: Bool = true
  
  var body: some View {

    VStack {
      if !showSignInVeiw && !isNotRegistered && !isLoading{
        NavigationStack {
          ProfileView(showSignInView: $showSignInVeiw)
        }
      }
    }
    .task {
      
      let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
      self.showSignInVeiw = authuser == nil ? true : false
      self.isNotRegistered = authuser == nil ? true : false
      await Task.sleep(3 * 1_000_000_000)
      
      self.isLoading = false
    }
    .fullScreenCover(isPresented: $showSignInVeiw) {
      NavigationStack {
        AuthenticationView(showSignInView: $showSignInVeiw, isNotRegistered: $isNotRegistered)
      }
    }
    .fullScreenCover(isPresented: $isNotRegistered) {
      NavigationStack {
        CreateUserView(isNotRegistered: $isNotRegistered)
      }
    }
    .fullScreenCover(isPresented: $isLoading) {
      NavigationStack {
        SplashScreenView()
      }
    }
  }
}

struct RootVeiw_Previews: PreviewProvider {
  static var previews: some View {
    RootVeiw()
  }
}
