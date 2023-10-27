//
//  RootVeiw.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI

struct RootVeiw: View {
  
  @State private var showSignInVeiw: Bool = false
  
  
    var body: some View {
      ZStack {
        NavigationStack {
          SettingsView(showSignInView: $showSignInVeiw)
        }
      }
      .onAppear {
        let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
        self.showSignInVeiw = authuser == nil ? true : false
      }
      .fullScreenCover(isPresented: $showSignInVeiw) {
        NavigationStack {
          AuthenticationView(showSignInView: $showSignInVeiw)
        }
      }
      
    }
}

struct RootVeiw_Previews: PreviewProvider {
    static var previews: some View {
        RootVeiw()
    }
}
