import SwiftUI
import UniformTypeIdentifiers

let types: [UTType] = [.fileURL, .url]

struct ContentView: View {
  @State private var image: NSImage?
  
  var body: some View {
    VStack {
      if let image = image {
        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        Text("Drag and drop an image here.")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.gray.opacity(0.3))
      }
    }
    .onDrop(of: types, isTargeted: nil, perform: performDrop)
  }
  
  func performDrop(providers: [NSItemProvider]) -> Bool {
    print("Drop detected")
    
    guard let provider = providers.first else { return false }
    
    provider.loadObject(ofClass: NSURL.self) { object, error in
      if let error = error {
        print("Error loading dropped item: \(error.localizedDescription)")
      } else if let url = object as? URL,
                let data = try? Data(contentsOf: url),
                let droppedImage = NSImage(data: data) {
        DispatchQueue.main.async {
          self.image = droppedImage
        }
      }
    }
    
    return true
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

