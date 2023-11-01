import SwiftUI

struct MessageEditor: View {
  @Binding var newMessageText: String
  @State private var isTyping: Bool = false
  var onTextChange: ((Bool) -> Void)?
  private let minHeight: CGFloat = 40.0
  private let lineHeight: CGFloat = 20.0
  private let maxLines: Int = 10
  
  var body: some View {
    let lines = newMessageText.components(separatedBy: "\n").count + 1
    let approximateLines = min(lines, maxLines)
    let height = max(minHeight, CGFloat(approximateLines) * lineHeight)
    
    // ScrollViewを使用してスクロールを可能にする
    ScrollView {
      TextEditor(text: $newMessageText)
        .onChange(of: newMessageText) { newValue in
          let isEmpty = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          if !isEmpty && !isTyping {
            isTyping = true
            onTextChange?(true)
          } else if isEmpty && isTyping {
            isTyping = false
            onTextChange?(false)
          }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color("PartsColor"), lineWidth: 1)
        )
        .frame(minHeight: minHeight, maxHeight: height)
    }
    .frame(height: height)
  }
}

struct MessageEditor_Previews: PreviewProvider {
  @State static var dummyText: String = ""
  
  static var previews: some View {
    MessageEditor(newMessageText: $dummyText)
  }
}
