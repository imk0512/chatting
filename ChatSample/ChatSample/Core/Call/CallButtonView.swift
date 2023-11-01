import SwiftUI
import CallKit

struct CallButtonView: View {
    @EnvironmentObject var callKitManager: CallKitManager

    var body: some View {
        Button(action: {
            startCall()
        }) {
            Image(systemName: "phone.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
        }
    }

    private func startCall() {
        // CallKitを使用して通話を開始するロジック
        // ここでは仮のUUIDを使用していますが、実際の実装では一意のIDを使用してください。
        let callUUID = UUID()
        let handle = CXHandle(type: .phoneNumber, value: "recipientPhoneNumber")
        let startCallAction = CXStartCallAction(call: callUUID, handle: handle)
        startCallAction.isVideo = true

        let transaction = CXTransaction(action: startCallAction)

      callKitManager.callController.request(transaction, completion: { error in
          if let error = error {
              print("Error starting call: \(error.localizedDescription)")
              return
          }
          // 通話開始後の追加の処理（必要に応じて）
      })
    }
}
