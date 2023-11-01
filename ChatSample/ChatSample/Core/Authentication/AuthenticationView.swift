
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
  
  @StateObject private var viewModel = AuthenticationViewModel()
  @Binding var showSignInView: Bool
  @Binding var isNotRegistered: Bool
  
  
  var body: some View {
    ZStack {
      Image("view")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .edgesIgnoringSafeArea(.all)
    }
      VStack {
        //          NavigationLink {
        //            SignInEmailView(showSignInView: $showSignInView)
        //          } label : {
        //            Text("Sign In With Email")
        //              .font(.headline)
        //              .foregroundColor(.white)
        //              .frame(height: 55)
        //              .frame(maxWidth: .infinity)
        //              .background(Color.blue)
        //              .cornerRadius(10)
        //          }
        
        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
          Task {
            do {
              let authDataResult = try await viewModel.signInGoogle()
              let registeredStatus = try await viewModel.checkExist(userId: authDataResult.uid)
              isNotRegistered = registeredStatus
              showSignInView = false
            } catch {
              print(error)
            }
          }
        }
        .padding()
      }
      .padding()
      .navigationTitle("Sign in ")
    
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AuthenticationView(showSignInView: .constant(false), isNotRegistered:.constant(false))
    }
  }
}
