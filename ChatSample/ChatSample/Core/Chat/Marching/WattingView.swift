//
//  WattingView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/31.
//

import SwiftUI

struct WattingView: View {
  
  @Binding var isCancel: Bool
  var body: some View {
    VStack {
      LottieView(name: "Searching", loopMode: .loop).frame(width: 600.0,height: 600.0)
      
      Button(action: {
          isCancel = true
      }, label: {
          Text("Cancel")
              .foregroundColor(.white)
              .frame(width: 150, height: 50)
              .background(Color("PartsColor"))
              .cornerRadius(10)
      })

    }
  }
  
}

struct WattingView_Previews: PreviewProvider {
  static var previews: some View {
    WattingView(isCancel: .constant(false))
  }
}
