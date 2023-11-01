import CallKit
import SwiftUI

class CallKitManager: NSObject, CXProviderDelegate, ObservableObject {
  var provider: CXProvider?
  var callController = CXCallController()
  
  override init() {
    super.init()
    
    let configuration = CXProviderConfiguration(localizedName: "ChatSample")
    configuration.supportsVideo = true
    configuration.maximumCallsPerCallGroup = 1
    configuration.supportedHandleTypes = [.phoneNumber]
    
    provider = CXProvider(configuration: configuration)
    provider?.setDelegate(self, queue: nil)
  }
  
  // MARK: - CXProviderDelegate methods
  func providerDidReset(_ provider: CXProvider) {
    // 通話がリセットされたときの処理を実装します。
  }
  
  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    action.fulfill()
  }
  
  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    action.fulfill()
  }
  
  func reportIncomingCall(uuid: UUID, handle: String, completion: ((Error?) -> Void)? = nil) {
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
    update.hasVideo = true
    
    provider?.reportNewIncomingCall(with: uuid, update: update, completion: { error in
      if let error = error {
        print("Error reporting incoming call: \(error.localizedDescription)")
        completion?(error)
        return
      }
      completion?(nil)
    })
  }
  
  func answerCall() {
    // ここに通話を受け入れた時のロジックを追加する
  }
  
  func endCall() {
    // ここに通話を終了するロジックを追加する
  }
  
}
