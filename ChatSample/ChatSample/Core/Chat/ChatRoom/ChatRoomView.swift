import SwiftUI


struct ChatRoomView: View {
  
  @StateObject private var viewModel: ChatRoomViewModel
  @State private var newMessageText = ""
  @State private var selectedImage: UIImage?
  @State private var isImagePickerPresented = false
  @State private var isPresentedCameraView = false
  @State private var isPhotoSend = false
  @State private var capturedImage: UIImage?
  @State private var isImagePreviewPresented: Bool = false
  @State private var previewImageURL: URL?
  
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
  init(matchId: String,friendId:String) {
    let chatRoomViewModel = ChatRoomViewModel(matchId: matchId,friendId: friendId)
    self._viewModel = StateObject(wrappedValue: chatRoomViewModel)
  }
  
  var body: some View {
    VStack {
      ScrollView {
        ScrollViewReader { proxy in
          VStack(spacing: 10) {
            ForEach(viewModel.massageList) { message in
              HStack(alignment: .bottom) {
                if message.senderId == viewModel.senderId {
                  if message.type == "message" {
                    if message.massageText != "..."  {
                      if let timestamp = message.timestamp {
                        Spacer()
                        VStack {
                          Text(timestamp.formattedTime()).font(.system(size: 12))
                        }
                      }
                      
                    } else {
                      Spacer()
                      VStack {
                        Text("").font(.system(size: 12))
                      }
                      
                    }
                  } else {
                    
                    Spacer()
                    if let timestamp = message.timestamp {
                      VStack {
                        Text(timestamp.formattedTime()).font(.system(size: 12))
                      }
                    }
                  }
                }
                
                // massageTextがある場合
                if message.type == "message" {
                  if message.massageText == "..."  {
                    if message.senderId != viewModel.senderId {
                      Text(message.massageText)
                        .padding(10)
                        .background(message.senderId == viewModel.senderId ? Color("ChatTextMy") : Color("ChatTextOther"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                  } else {
                    Text(message.massageText)
                      .padding(10)
                      .background(message.senderId == viewModel.senderId ? Color("ChatTextMy") : Color("ChatTextOther"))
                      .foregroundColor(.white)
                      .cornerRadius(10)
                  }
                  
                }
                else if message.type == "image" {
                  if let imageURL = URL(string: message.imagePath) {
                    AsyncImage(url: imageURL) { image in
                      image.resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 300)
                        .cornerRadius(10)
                        .onTapGesture {
                          self.previewImageURL = imageURL
                          self.isImagePreviewPresented = true
                        }
                        .onAppear {
                          scrollToBottom(proxy)
                        }
                      
                    } placeholder: {
                      ProgressView()
                        .frame(width: 100, height: 100)
                        .background(message.senderId == viewModel.senderId ? Color("ChatTextMy") : Color("ChatTextOther"))
                        .cornerRadius(10)
                    }
                    .cornerRadius(10)
                  } else {
                    ProgressView()
                      .frame(width: 100, height: 100)
                      .background(message.senderId == viewModel.senderId ? Color("ChatTextMy") : Color("ChatTextOther"))
                      .cornerRadius(10)
                  }
                }
                
                
                if message.senderId != viewModel.senderId {
                  if message.type == "message" {
                    if message.massageText != "..."  {
                      if let timestamp = message.timestamp {
                        VStack {
                          Text(timestamp.formattedTime()).font(.system(size: 12))
                        }
                      }
                      Spacer()
                    } else {
                      VStack {
                        Text("").font(.system(size: 12))
                      }
                      
                      Spacer()
                    }
                  } else {
                    if let timestamp = message.timestamp {
                      VStack {
                        Text(timestamp.formattedTime()).font(.system(size: 12))
                      }
                    }
                    Spacer()
                  }
                }
              }
              .id(message.id)
              
            }
          }
          .padding()
          .onAppear {
            Task {
              try? await viewModel.loadCurrentUser()
              try? await viewModel.loadFriend()
              
              viewModel.observerListObject()
              scrollToBottom(proxy)
            }
          }
          .onChange(of: viewModel.massageList) { _ in
            scrollToBottom(proxy)
          }
        }
      }
      .onTapGesture {
        endEditing()
      }
      
      HStack(alignment: .bottom) {
        Button(action: {
          Task {
            newMessageText = ""
            await viewModel.setTypingStatus(isTyping: false)
          }
          isImagePickerPresented.toggle()
        }) {
          Image(systemName: "photo.on.rectangle")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Color("PartsColor"))
            .colorMultiply(isImagePickerPresented ? .clear : .white)
        }
        .disabled(isImagePickerPresented)
        .padding([.leading, .trailing], 8)
        .padding(.bottom, 10)
        
        Button(action: {
          Task {
            await viewModel.setTypingStatus(isTyping: false)
          }
          isPresentedCameraView = true
        }) {
          Image(systemName: "camera")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Color("PartsColor"))
            .colorMultiply(isImagePickerPresented ? .clear : .white)
        }
        .disabled(isImagePickerPresented)
        .padding([.leading, .trailing], 8)
        .padding(.bottom, 10)
        
        if !isImagePickerPresented {
          MessageEditor(newMessageText: $newMessageText) { isTyping in
            Task {
              await viewModel.setTypingStatus(isTyping: isTyping)
            }
          }
        } else {
          Text("Please select one photo")
            .foregroundColor(Color("PartsColor"))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
        }
        
        Button(action: {
          Task {
            let currentMessageText = newMessageText
            newMessageText = ""
            isImagePickerPresented = false
            if let image = selectedImage {
              await viewModel.sendImageMessage(image: image)
            } else {
              
              await viewModel.sendTextMessage(massageText: currentMessageText)
            }
            newMessageText = ""
            selectedImage = nil
          }
        }) {
          Image(systemName: "paperplane.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Color("PartsColor"))
        }
        .padding(.bottom, 10)
        .disabled(newMessageText.isEmpty && selectedImage == nil)
      }
      
      if isImagePickerPresented {
        ImagePicker(selectedImage: $selectedImage,isImagePickerPresented: $isImagePickerPresented )
      }
    }
    .onChange(of: isPhotoSend) { shouldSend in
      if shouldSend {
        Task {
          if let image = capturedImage {
            await viewModel.sendImageMessage( image: image)
          }
          
          isPhotoSend = false
          capturedImage = nil
        }
      }
    }
    .fullScreenCover(isPresented: $isPresentedCameraView) {
      CameraView(image: $capturedImage,isPhotoSend: $isPhotoSend).ignoresSafeArea()
    }
    .padding()
    .fullScreenCover(isPresented: $isImagePreviewPresented) {
      VStack {
        HStack {
          Button(action: {
            isImagePreviewPresented = false
          }) {
            Image(systemName: "xmark.circle.fill")
              .font(.largeTitle)
              .foregroundColor(.white)
              .padding()
              .background(Color.black.opacity(0.5))
              .clipShape(Circle())
          }
          Spacer()
        }
        Spacer()
        
        if let url = previewImageURL {
          AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
              image.resizable()
                .scaledToFit()
            @unknown default:
              ProgressView()
            }
          }
        } else {
          Text("Unable to load image")
        }
        Spacer()
      }
    }
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        HStack(spacing: 10) {
          Circle()
            .fill(Color.gray)
            .frame(width: 40, height: 40)
            .overlay(
              Group {
                if let friendImage = viewModel.friendImage {
                  Image(uiImage: friendImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                } else {
                  // viewModel.friendImageがnilのときの表示
                  Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                }
              }
            )
          Text(viewModel.friend?.name ?? "" )
            .font(.headline)
        }
      }
    }
  }
  
  func scrollToBottom(_ proxy: ScrollViewProxy) {
    if let lastMessage = viewModel.massageList.last {
      withAnimation {
        proxy.scrollTo(lastMessage.id, anchor: .bottom)
      }
    }
  }
 
}

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
