//
//  CreateUserViewModel.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/28.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class CreateUserViewModel: ObservableObject {
  
  @Published var name = ""
  @Published var selectedGender = ""
  @Published var selectedDate = Date()
  @Published var profileImagePath = ""
  
  
  func createUser() async throws -> Bool{
    
    guard name != "" else {
      print("name empty")
      return false
    }
    
    guard selectedGender != "" else {
      print("Gender empty")
      return false
    }
    
    // DateをStringに変換
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let birth = dateFormatter.string(from: selectedDate)
    
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    var data = DBUser(auth:authDataResult, name: name, sex: selectedGender, birth: birth,profileImagePath: profileImagePath)
    
    try await UserManager.shared.createNewUser(user: data)
    
    return true
  }
  
  func dateLabel() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let birth = dateFormatter.string(from: selectedDate)
    return birth
  }
  
  func saveProfileImage(item: PhotosPickerItem) {
    
    Task {
      let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
     
      guard let data = try await item.loadTransferable(type: Data.self) else { return }
      let (path, name) = try await ImageFileManager.shared.saveImage(data: data,userId: authDataResult.uid)
      profileImagePath = path
    }
  }
}
