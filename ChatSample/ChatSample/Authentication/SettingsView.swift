//
//  SettingView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
  
  
  func logOut() {
    
  }
}


struct SettingView: View {
    var body: some View {
      List {
        Button("Logout"){
          
        }
        
      }
      .navigationBarTitle("Settings")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
