import SwiftUI

struct ChatRoomView: View {
    @State private var messageText: String = ""
    @State private var messages: [String] = [] 

    var body: some View {
        VStack {
            // メッセージ一覧
            List(messages, id: \.self) { message in
                Text(message)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(5)
            }
            
            // メッセージ入力フィールド
            HStack {
                TextField("メッセージを入力", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !messageText.isEmpty {
                        messages.append(messageText)
                        messageText = ""
                    }
                }) {
                    Text("送信")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(10)
        }
        .padding(10)
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView()
    }
}
