//
//  ApprovalView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/28.
//

import SwiftUI

struct MatchingView: View {
  @StateObject private var viewModel = MatchingViewModel()
  @State private var isCancel: Bool = false

  @Binding var matchId: String
  @Binding var friendId: String
  @Binding var isMatchingSearch: Bool
  
  //  @State private var matchId: String
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
  
  var body: some View {
    VStack {
      if viewModel.matching?.status == "pending" {
        VStack {
          if let image = viewModel.counterpartImage  {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 200, height: 200)
              .background(Color.teal)
              .clipShape(Circle())
              .padding(.vertical, 10)
            
            Text(viewModel.counterpartUser?.name ?? "")
              .frame(width: 250)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
              .cornerRadius(10)
            
            Text("Gender:\(viewModel.counterpartUser?.sex ?? "")")
              .frame(width: 250)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
              .cornerRadius(10)
            
            Text("Birth\(viewModel.counterpartUser?.birth ?? "")")
              .frame(width: 250)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
              .cornerRadius(10)
            
            if !viewModel.isWaiting() {
              HStack{
                
                Button("Cancel") {
                  Task {
                    try? await viewModel.updateMatchingCancel()
                    presentationMode.wrappedValue.dismiss()
                  }
                  
                }
                .foregroundColor(.white)
                .frame(width: 150, height: 50)
                .background(Color("PartsColor"))
                .cornerRadius(10)
                
                Button("Approve") {
                  Task {
                    try? await viewModel.updateMatchingConsent()
                  }
                }
                .foregroundColor(.white)
                .frame(width: 150, height: 50)
                .background(Color("PartsColor"))
                .cornerRadius(10)
                
              }
              
            } else {
              ProgressView("Waiting for partner...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            }
          } else {
            LottieView(name: "Match", loopMode: .loop).frame(width: 600.0,height: 600.0)
          }
        }
        .task {
          try? await viewModel.getMatchingUser()
        }
      } else if viewModel.matching?.status == "waiting" {
        WattingView(isCancel: $isCancel)
          .task {
            viewModel.initCounterpartUser()
          }.onChange(of: isCancel) { isCancel in
            Task {
              if isCancel {
                try? await viewModel.matchingCancel()
                presentationMode.wrappedValue.dismiss()
              }
            }
          }
      } else if viewModel.matching?.status == "chatting" {
        VStack{
          
        }.task {
          try? await viewModel.createFriend()
          if let matchId = viewModel.matchingId , let counterpartUserId = viewModel.counterpartUser?.userId {
            self.matchId = matchId
            self.friendId = counterpartUserId
          }
          
          self.isMatchingSearch = false
        }
        
      }
    }
    .task {
      try? await viewModel.loadCurrentUser()
      try? await viewModel.searchMatching()
      if viewModel.matchingId == nil {
        try? await viewModel.createMatching()
      } else {
        try? await viewModel.updateMatching()
      }
      try? await viewModel.getMatching(matchingId: viewModel.matchingId  ?? "")
    }
  }
  
}
