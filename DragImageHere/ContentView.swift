import SwiftUI
import UniformTypeIdentifiers

let types: [UTType] = [.fileURL]

struct ContentView: View, DropDelegate {
  
  func performDrop(info: DropInfo) -> Bool {
    // Check if there are items conforming to the specified types
    if let provider = info.itemProviders(for: types).first {
      // Process the first item provider that conforms to the specified types
      provider.loadObject(ofClass: NSURL.self) { object, error in
        if let error = error {
          print("Error loading dropped item: \(error.localizedDescription)")
        } else if let url = object as? URL, let data = try? Data(contentsOf: url), let droppedImage = NSImage(data: data) {
          DispatchQueue.main.async {
            self.image = droppedImage
          }
        }
      }
      return true
    }
    
    // If there are no items conforming to the specified types, check for file promise receivers in the pasteboard
    let pasteboard = NSPasteboard(name: .drag)
    guard let filePromises = pasteboard.readObjects(forClasses: [NSFilePromiseReceiver.self], options: nil),
          let receiver = filePromises.first as? NSFilePromiseReceiver else {
      return false
    }
    
    // Process the first file promise receiver
    let queue = OperationQueue()
    receiver.receivePromisedFiles(atDestination: URL.temporaryDirectory, operationQueue: queue) { (url, error) in
      if let error = error {
        print("Error loading dropped item from pasteboard: \(error.localizedDescription)")
      } else if let data = try? Data(contentsOf: url), let droppedImage = NSImage(data: data) {
        DispatchQueue.main.async {
          self.image = droppedImage
        }
      }
    }
    
    return true
  }
  
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
    .onDrop(of: types, delegate: self)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

