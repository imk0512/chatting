//
//  RootVeiw.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI


struct RootVeiw: View {
  @StateObject private var viewModel = ProfileViewModel()
  @State private var showSignInVeiw: Bool = false
  @State private var isNotRegistered: Bool = false
  @State private var isLoading: Bool = true
  
  var body: some View {

    VStack {
      if !showSignInVeiw && !isNotRegistered{
        NavigationStack {
          ProfileView(showSignInView: $showSignInVeiw, isLoading:$isLoading)
        }.fullScreenCover(isPresented: $isLoading) {
          NavigationStack {
            SplashScreenView()
          }
        }
      }
    }
    .task {

      let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
      self.showSignInVeiw = authuser == nil ? true : false
      self.isNotRegistered = authuser == nil ? true : false
    }
    .fullScreenCover(isPresented: $showSignInVeiw) {
      NavigationStack {
        AuthenticationView(showSignInView: $showSignInVeiw, isNotRegistered: $isNotRegistered, isLoading: $isLoading)
      }
    }
    .fullScreenCover(isPresented: $isNotRegistered) {
      NavigationStack {
        CreateUserView(isNotRegistered: $isNotRegistered,isLoading: $isLoading)
      }
    }
    
  }
}

struct RootVeiw_Previews: PreviewProvider {
  static var previews: some View {
    RootVeiw()
  }
}
