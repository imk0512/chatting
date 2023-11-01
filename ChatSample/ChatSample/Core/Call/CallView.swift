import SwiftUI

struct CallView: View {
    // 通話中のユーザー情報やステータスなどを表示するための変数を追加します。
    // 例:
    var recipientName: String

    var body: some View {
        VStack {
            Text("通話中: \(recipientName)")
            // その他のUI要素（例: 終了ボタン、ミュートボタンなど）
        }
    }
}
