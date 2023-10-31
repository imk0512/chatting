import SwiftUI


struct ChatRoomView: View {
  @StateObject private var viewModel: ChatRoomViewModel
  @State private var newMessageText = ""
  @State private var selectedImage: UIImage?
  @State private var isImagePickerPresented = false
  
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
  init(matchId: String) {
    let chatRoomViewModel = ChatRoomViewModel(matchId: matchId)
    self._viewModel = StateObject(wrappedValue: chatRoomViewModel)
  }
  
  var body: some View {
    
    VStack {
      ScrollView {
        ScrollViewReader { proxy in
          VStack(spacing: 10) {
            ForEach(viewModel.massageList) { message in
              HStack {
                if message.senderId == viewModel.senderId {
                  Spacer()
                  if let timestamp = message.timestamp {
                    VStack {
                      Spacer()
                      Text(timestamp.formattedTime()).font(.system(size: 12))
                    }
                  }
                }
                Text(message.massageText)
                  .padding(10)
                  .background(message.senderId == viewModel.senderId ? Color("Parts2Color") : Color("ChatColor2"))
                  .foregroundColor(.white)
                  .cornerRadius(10)
                if message.senderId != viewModel.senderId {
                  if let timestamp = message.timestamp {
                    VStack {
                      Text(timestamp.formattedTime()).font(.system(size: 12))
                    }
                  }
                  Spacer()
                }
              }
              .id(message.id)
              
            }
          }
          .padding()
          .onAppear {
            Task {
              try? await viewModel.loadCurrentUser()
              viewModel.observerListObject()
            }
          }
          .onChange(of: viewModel.massageList) { _ in
            // メッセージリストが更新されたら最下部にスクロール
            scrollToBottom(proxy)
          }
        }
      }
      if let image = selectedImage {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
      }
      
      HStack {
        Button(action: {
          isImagePickerPresented.toggle()
        }) {
          Image(systemName: "photo.on.rectangle")
            .resizable()
            .frame(width: 24, height: 24)
        }.sheet(isPresented: $isImagePickerPresented) {
          ImagePicker(selectedImage: $selectedImage)
        }
        
        
        Button(action: {
        }) {
          Image(systemName: "camera")
            .resizable()
            .frame(width: 24, height: 24)
          
        }
        
        MessageEditor(newMessageText: $newMessageText)

        Button(action: {
          viewModel.sendMassage(massageText: newMessageText)
          newMessageText = ""
        }) {
          Image(systemName: "paperplane.fill")
            .resizable()
            .frame(width: 34, height: 34)
        }
      }
      
    }
    .padding()
    .navigationTitle("Chat Room")
  }
  
  func scrollToBottom(_ proxy: ScrollViewProxy) {
    // 最後のメッセージにスクロール
    if let lastMessage = viewModel.massageList.last {
      withAnimation {
        proxy.scrollTo(lastMessage.id, anchor: .bottom)
      }
    }
  }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need to update the view controller
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let uiImage = info[.originalImage] as? UIImage {
              parent.selectedImage = uiImage
          }

          picker.dismiss(animated: true, completion: nil)
      }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

struct ChatRoomView_Previews: PreviewProvider {
  static var previews: some View {
    ChatRoomView(matchId: "3B349281-94C2-40C5-8466-41B5BFE31B13")
  }
}
