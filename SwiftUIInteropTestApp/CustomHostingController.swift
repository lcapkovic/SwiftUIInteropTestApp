import SwiftUI

class CustomHostingController<Content>: UIHostingController<Content> where Content: View {

    override func loadView() {
        super.loadView()
        
        if debugBorderEnabled {
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.systemGreen.cgColor
        }
    }
    
    private let debugBorderEnabled: Bool = true
}
