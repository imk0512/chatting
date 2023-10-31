//
//  WatingView.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/28.
//

import SwiftUI
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
  
  let name: String
  let loopMode: LottieLoopMode
  var animationView = LottieAnimationView()
  
  init(name: String, loopMode: LottieLoopMode) {
    self.name = name
    self.loopMode = loopMode
  }
  
  
  func makeUIView( context: UIViewRepresentableContext<LottieView>) -> some UIView {
    let view = UIView()
    animationView.animation = LottieAnimation.named(name)
    animationView.loopMode = loopMode
    animationView.contentMode = .scaleAspectFill
    animationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(animationView)
    
    NSLayoutConstraint.activate([
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
    ])
    
    return view
  }
  
  func updateUIView(_ uiView: UIViewType,  context: UIViewRepresentableContext<LottieView>) {
    animationView.play()
  }
  
  
}

struct WatingView_Previews: PreviewProvider {
  static var previews: some View {
    LottieView(name: "Match" , loopMode: .loop)
  }
}
