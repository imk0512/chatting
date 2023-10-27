//
//  ProfileView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI


@MainActor
final class ProfileViewModel: ObservableObject {
  
  @Published private(set) var user: DBUser? = nil
  
  func loadCurrentUser() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
  }
}

struct ProfileView: View {
  
  @StateObject private var viewModel = ProfileViewModel()
  @State private var url: URL? = nil
  @Binding var showSignInView: Bool
  
  
  var body: some View {
    VStack {
      
      if let url {
        AsyncImage(url: url) { image in
            image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .background(Color.teal)
            .clipShape(Circle())
            .padding(.vertical, 10)
        } placeholder: {
          ProgressView()
            .frame(width: 200, height: 200)
        }
      }
     
      
      if let user = viewModel.user {
        // 名前入力エリア
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
      
      NavigationLink(destination: ChatRoomView()) {
          Text("Matching Start")
              .foregroundColor(.white)
              .frame(width: 280, height: 55)
              .background(Color("PartsColor"))
              .cornerRadius(10)
      }
      .onTapGesture {
         // TODO
      }
    }
    .task {
      try?  await viewModel.loadCurrentUser()
      
      if let auth = viewModel.user, let path = viewModel.user?.profileImagePath {
        let url = try? await ImageFileManager.shared.getUrlForImage(path: path )
        self.url = url
      }
    }
//    .navigationTitle("Profile")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink {
          SettingsView(showSignInView: $showSignInView)
        } label: {
          Image(systemName: "gear")
            .font(.headline)
        }
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ProfileView(showSignInView: .constant(false))
    }
  }
}
