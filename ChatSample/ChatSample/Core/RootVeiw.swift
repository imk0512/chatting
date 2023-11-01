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

  @State private var pageType: String = "Profile"
  
  var body: some View {
    NavigationView {
      VStack {
        if !showSignInVeiw && !isNotRegistered {
          TabbarView(showSignInView: $showSignInVeiw)
        } else {
          SplashScreenView()
        }
      }
      .task {
        let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
        self.showSignInVeiw = authuser == nil ? true : false
        self.isNotRegistered = authuser == nil ? true : false
        print("self.showSignInVeiw",self.showSignInVeiw)
        print("self.isNotRegistered",self.isNotRegistered)
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
    }
  }
}

struct RootVeiw_Previews: PreviewProvider {
  static var previews: some View {
    RootVeiw()
  }
}
