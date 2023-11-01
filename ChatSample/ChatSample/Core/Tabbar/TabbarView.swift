//
//  TabbarView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/11/01.
//

import SwiftUI

struct TabbarView: View {
  
  @Binding var showSignInView: Bool
  @StateObject private var profileViewModel = ProfileViewModel()
  @StateObject private var friendsviewModel = FriendsViewModel()
  
  @State var isLoading: Bool = true
  
  var body: some View {
    Group {
      TabView {
        
        if !isLoading {
          ProfileView(viewModel: profileViewModel, showSignInView: $showSignInView)
            .tabItem {
              Image(systemName: "person.fill")
              Text("Profile")
            }
          
          FriendsView(viewModel: friendsviewModel)
            .tabItem {
              Image(systemName: "message.fill")
              Text("Friends")
            }
        }
      }
    }
    .task {
      try? await profileViewModel.loadCurrentUser()
      try? await friendsviewModel.loadFriends()
      let twoSecondsInNanoseconds: UInt64 = 2 * 1_000_000_000
      try? await Task.sleep(nanoseconds: twoSecondsInNanoseconds)
      isLoading = false
    }
    .fullScreenCover(isPresented: $isLoading) {
      NavigationStack {
        SplashScreenView()
      }
    }
  }
}

