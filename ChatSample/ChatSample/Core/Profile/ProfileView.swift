//
//  ProfileView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI
import UIKit



struct ProfileView: View {
  
  @State private var image: UIImage? = nil
  @State private var shouldNavigateToChat: Bool = false
  @State private var isMatchingSearch: Bool = false
  @State private var matchId: String = ""
  @State private var friendId: String = ""
  @State private var navigateToChatRoom: Bool = false
  
  @ObservedObject var viewModel: ProfileViewModel
  @Binding var showSignInView: Bool
  
  
  var body: some View {
    
    NavigationView {
      VStack {
        if let user = viewModel.user {
          if let image = viewModel.userImage {
            
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 200, height: 200)
              .background(Color.teal)
              .clipShape(Circle())
              .padding(.vertical, 10)
            
            Text(user.name ?? "")
              .frame(width: 250)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
              .cornerRadius(10)
            
            Text("Gender \(user.sex ?? "")")
              .frame(width: 250)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
              .cornerRadius(10)
            
            Text("Birth \(user.birth ?? "")")
              .frame(width: 250)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
              .cornerRadius(10)
          }
          
          Button(action: {
            isMatchingSearch = true
          }) {
            Text("Matching Start")
              .foregroundColor(.white)
              .frame(width: 280, height: 55)
              .background(Color("PartsColor"))
              .cornerRadius(10)
          }
          
          NavigationLink(destination: ChatRoomView(matchId: matchId,friendId: friendId), isActive: $navigateToChatRoom) {
            EmptyView()
          }.onDisappear {
            matchId = ""
        }
        }
      }
      .fullScreenCover(isPresented: $isMatchingSearch) {
        NavigationStack {
          MatchingView(matchId: $matchId, friendId: $friendId, isMatchingSearch: $isMatchingSearch)
        }
      }
      .task {
        if viewModel.user == nil{
          try?  await viewModel.loadCurrentUser()
        }
      }
      .onChange(of: isMatchingSearch) { newValue in
        if !newValue && !matchId.isEmpty{
          navigateToChatRoom = true
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink {
            SettingsView(showSignInView: $showSignInView)
          } label: {
            Image(systemName: "list.bullet")
              .font(.headline)
          }
        }
      }
    }
    
  }
}
