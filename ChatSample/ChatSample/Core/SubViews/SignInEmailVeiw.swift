//
//  SignInEmailView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
  
  @Published var email = ""
  @Published var password = ""
  
  func signUp() async throws {
    guard !email.isEmpty, !password.isEmpty else {
        print("Email or password found")
        return
    }
    
    let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
    let user = DBUser(auth: authDataResult)
    try await UserManager.shared.createNewUser(user: user)
  }
  
  func signIn() async throws {
    guard !email.isEmpty, !password.isEmpty else {
        print("Email or password found")
        return
    }
    
    try await AuthenticationManager.shared.signInUser(email: email, password: password)
  }
}

struct SignInEmailView: View {
  
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
  
    var body: some View {
        VStack {
          TextField("Email... ", text: $viewModel.email)
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
          
          SecureField("Password... ", text: $viewModel.password)
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
          
          Button {
              Task {
                  do {
                    try await  viewModel.signUp()
                    showSignInView = false
                    return
                  } catch {
                    print(error)
                    
                  }
                
                do {
                  try await  viewModel.signIn()
                  showSignInView = false
                  return
                } catch {
                  print(error)
                  
                }
              }
          } label : {
            Text("Sign In")
              .font(.headline)
              .foregroundColor(.white)
              .frame(height: 55)
              .frame(maxWidth: .infinity)
              .background(Color.blue)
              .cornerRadius(10)
          }
          
          Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
      }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
      SignInEmailView(showSignInView: .constant(false))
    }
}
