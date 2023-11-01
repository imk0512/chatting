//
//  Friends.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/31.
//

import SwiftUI

struct FriendsView: View {
  
  @ObservedObject var viewModel: FriendsViewModel
  
  
  var body: some View {
    VStack {
      if let friends = viewModel.friends {
        List(friends) { friend in
          HStack {
            if let url = URL(string: friend.profileImageUrl ?? "") {
              AsyncImage(url: url) { image in
                image.resizable().scaledToFit().frame(width: 50, height: 50).clipShape(Circle())
              } placeholder: {
                ProgressView()
              }
            }
            Text(friend.name ?? "No Name")
            Spacer()
            if let matchId = friend.matchId {
              NavigationLink(destination: ChatRoomView(matchId: matchId,friendId:friend.userId)) {
                Image(systemName: "message.fill")
                  .resizable()
                  .frame(width: 24, height: 24)
              }
            }
          }.padding(.bottom, 10)
        }
      } else {
        Text("No Data")
      }
      
    }
  }
}

