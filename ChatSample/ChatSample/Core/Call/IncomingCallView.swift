import SwiftUI

struct IncomingCallView: View {
    @EnvironmentObject var callKitManager: CallKitManager
    var callerName: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Incoming Call")
                .font(.largeTitle)
                .padding()
            
            Text(callerName)
                .font(.title)
            
            HStack(spacing: 50) {
                Button(action: {
                    // Decline Call
                    callKitManager.endCall()
                }) {
                    Image(systemName: "phone.down.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    // Accept Call
                    callKitManager.answerCall()
                }) {
                    Image(systemName: "phone.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                }
            }
        }
    }
}
