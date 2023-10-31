//
//  ProfileView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI
import UIKit



struct ProfileView: View {
  
  @StateObject private var viewModel = ProfileViewModel()
  @State private var image: UIImage? = nil
  @Binding var showSignInView: Bool
  @Binding var isLoading: Bool
  
  var body: some View {
    VStack {
      
      if let user = viewModel.user {
        if let image = user.profileImage {
          
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .background(Color.teal)
            .clipShape(Circle())
            .padding(.vertical, 10)

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
        
        NavigationLink(destination: MatchingView()) {
          Text("Matching Start")
            .foregroundColor(.white)
            .frame(width: 280, height: 55)
            .background(Color("PartsColor"))
            .cornerRadius(10)
        }.isDetailLink(false)
      }
    }
    .task {
      if viewModel.user == nil{
        try?  await viewModel.loadCurrentUser()
        await Task.sleep(2 * 1_000_000_000)
      }
      
      isLoading = false
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        if !isLoading {
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

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ProfileView(showSignInView: .constant(false),isLoading: .constant(false) )
    }
  }
}
