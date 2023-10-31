import SwiftUI

struct CoverProgressView: View {
  var body: some View {
    VStack {
      ProgressView()
      Text("Loading...")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white.opacity(0.5))
  }
}

struct CoverProgressView_Previews: PreviewProvider {
  static var previews: some View {
    CoverProgressView()
  }
}
