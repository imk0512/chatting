import SwiftUI

struct MessageEditor: View {
    @Binding var newMessageText: String
    private let minHeight: CGFloat = 40.0
    private let lineHeight: CGFloat = 22.0
    private let maxLines: Int = 10
    
    var body: some View {
        let lines = newMessageText.components(separatedBy: "\n").count + 1
        let approximateLines = min(lines, maxLines)
        let height = max(minHeight, CGFloat(approximateLines) * lineHeight)

        // ScrollViewを使用してスクロールを可能にする
        ScrollView {
            TextEditor(text: $newMessageText)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .frame(minHeight: minHeight, maxHeight: height) // maxHeightを指定して最大高さを設定
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
