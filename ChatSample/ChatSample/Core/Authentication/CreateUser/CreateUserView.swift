//
//  CreateUserView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI
import PhotosUI

struct CreateUserView: View {
  
  @StateObject private var viewModel = CreateUserViewModel()
  @Binding var isNotRegistered: Bool
  @State private var selectedImage: PhotosPickerItem?
  @State private var uiImage: UIImage?
  
  private func loadImageFromSelectedPhoto(photo: PhotosPickerItem?) async {
    if let data = try? await photo?.loadTransferable(type: Data.self) {
      self.uiImage = UIImage(data: data)
    }
  }

  
  var body: some View {
    VStack {
      
      if let uiImage = uiImage {
        
        PhotosPicker(selection: $selectedImage, matching: .images,  photoLibrary: .shared()) {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .background(Color.teal)
            .clipShape(Circle())
            .padding(.vertical, 10)
        }
        .onChange(of: selectedImage) { selectedImage in
          Task {
            if let selectedImage {
              viewModel.saveProfileImage(item: selectedImage)
            }
            await loadImageFromSelectedPhoto(photo: selectedImage) }
        }
  
        
      } else {
        
        Button(action: {

        }) {
          PhotosPicker(selection: $selectedImage, matching: .images,  photoLibrary: .shared()) {
            Text("image")
              .foregroundColor(.white)
              .frame(width: 200, height: 200)
              .background(Color("Parts2Color"))
              .clipShape(Circle())
          }
          .onChange(of: selectedImage) { selectedImage in
            Task {
              if let selectedImage {
                viewModel.saveProfileImage(item: selectedImage)
                await loadImageFromSelectedPhoto(photo: selectedImage) }
              }
              
          }
        }
        .frame(width: 200, height: 200) // サークルのサイズ
        .background(Color("Parts2Color"))
        .clipShape(Circle()) // サークルにクリップ
      }
      
      // 名前入力エリア
      TextField("Name", text: $viewModel.name)
        .frame(width: 250)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .cornerRadius(10)
      
      // 性別セレクトボックス
      Picker("Gender", selection: $viewModel.selectedGender) {
        Text("Male").tag("Male")
        Text("Female").tag("Female")
        Text("None").tag("None")
      }
      .frame(width: 280,height: 40)
      .pickerStyle(SegmentedPickerStyle())
      .clipped()
      
      // 生年月日入力エリア
      DatePicker("Birth", selection: $viewModel.selectedDate, displayedComponents: .date)
        .frame(width: 250)
        .padding()
      
      Button("Save")  {
        Task {
          do {
            // createUser 関数を await で呼び出す
            let res = try await viewModel.createUser()
            if res {
              isNotRegistered = false
            }
            
          } catch {
            // エラーハンドリングを追加
            print("Error: \(error)")
          }
        }
      }
      .font(.headline)
        .foregroundColor(.white)
        .frame(width: 280,height: 55)
        .background(Color("PartsColor"))
        .cornerRadius(10)
    }
    .padding()
    
  }
  
}

struct CreateUserView_Previews: PreviewProvider {
  static var previews: some View {
    CreateUserView(isNotRegistered: .constant(false))
  }
}
