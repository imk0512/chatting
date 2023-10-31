//
//  SettingView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI




struct SettingsView: View {
  
  @StateObject private var viewModel = SettingsViewModel()
  @Binding var showSignInView: Bool
  @State private var redirectToSignIn = false
  
  var body: some View {
    List {
      Button("Logout"){
        Task {
          do {
            try viewModel.signOut()
            showSignInView = true
            redirectToSignIn = true
          } catch {
            print(error)
          }
        }
      }
    }
    .task {
      
    }
    .navigationBarTitle("Settings")
    .background(
      NavigationLink("", destination: RootVeiw(), isActive: $redirectToSignIn)
    )
    
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(showSignInView: .constant(false))
  }
}


extension SettingsView {
  private var emailSection: some View {
    
    Section {
      Button("Reset Password"){
        Task {
          do {
            try await viewModel.resetPassword()
            print("PASSWORD RESET!")
          } catch {
            print(error)
          }
        }
      }
      
      Button("Update Password"){
        Task {
          do {
            try await viewModel.updatePassword()
            print("PASSWORD UPDATED!")
          } catch {
            print(error)
          }
        }
      }
      
      Button("Update Email"){
        Task {
          do {
            try await viewModel.updateEmail()
            print("EMAIL UPDATED!")
          } catch {
            print(error)
          }
        }
      }
      
    } header: {
      Text("Email functions")
    }
  }
}
