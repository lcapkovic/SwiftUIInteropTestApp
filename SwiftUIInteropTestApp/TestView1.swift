//
//  TestView1.swift
//  SwiftUIInteropTestApp
//
//  Created by Lukas Capkovic on 3/27/22.
//

import SwiftUI
import Combine

class TestView1Settings: ObservableObject {
    @Published var width: CGFloat = 200
    @Published var leftAligned: Bool = false
    var invalidateIntrinsicContentSize: (() -> ())?
}

struct TestPage1: View {
    @StateObject var settings = TestView1Settings()
    @State var targetWidth: CGFloat = 0
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    var settingsView: some View {
        VStack {
            HStack {
                Text("Alignment")
                Spacer()
                Picker("Alignment", selection: $settings.leftAligned) {
                    Text("Left").tag(true)
                    Text("Right").tag(false)
                }.pickerStyle(.segmented)
                    .frame(maxWidth: 300)
            }
            HStack {
                Text("Width")
                Spacer()
                HStack {
                    Slider(value: $settings.width, in: 200...300)
                    Text("\(Int(settings.width))pt")
                        .frame(width:50, alignment: .trailing)
                }
                .frame(maxWidth: 300)
            }
            HStack {
                Spacer()
                Button(action: {
                    settings.invalidateIntrinsicContentSize?()
                }, label: {
                    Text("Invalidate intrinsic content size")
                    
                })
                .buttonStyle(.bordered)
            }
            HStack {
                Text("Target width")
                Spacer()
                HStack {
                    Slider(value: $targetWidth, in: 200...300)
                    Text("\(Int(targetWidth))pt")
                        .frame(width:50, alignment: .trailing)
                }
            }.padding([.top], 50)
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        settings.width = targetWidth
                    }
                }, label: {
                    Text("Animate to target width")
                    
                })
                .buttonStyle(.bordered)
            }
            HStack {
                Spacer()
                Button(action: {
                    settings.width = targetWidth
                }, label: {
                    Text("Jump to target width")
                    
                })
                .buttonStyle(.bordered)
            }
        }.frame(width: 400)
    }
}

struct TestView1_Previews: PreviewProvider {
    static var previews: some View {
        TestPage1()
    }
}

struct MainVCRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var settings: TestView1Settings
    
    func makeUIViewController(context: Context) -> TestVC1 {
        return TestVC1(settings: settings)
    }
    
    func updateUIViewController(_ uiViewController: TestVC1, context: Context) {}
    
    typealias UIViewControllerType = TestVC1
    
    
}

class TestVC1: UIViewController {
    var alignmentObserver: AnyCancellable?
    private let settings: TestView1Settings

    init(settings: TestView1Settings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = CustomHostingController(rootView: TestView1SelfSizingView().environmentObject(settings))
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//        hostingController.view.frame = CGRect(x: 0, y: 50, width: 10, height: 10)
    
        
        // Misc background stuff
        let borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.layer.borderColor = UIColor.secondarySystemFill.cgColor
        borderView.layer.borderWidth = 4
        borderView.layer.cornerCurve = .continuous
        borderView.layer.cornerRadius = 10
        borderView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(borderView, belowSubview: hostingController.view)
        
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            borderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            borderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            borderView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: borderView.centerYAnchor)
        ])
        
        let leftAlignedConstraint = hostingController.view.leadingAnchor.constraint(equalTo: borderView.leadingAnchor)
        let rightAlignedConstraint = hostingController.view.trailingAnchor.constraint(equalTo: borderView.trailingAnchor)
        
        alignmentObserver = settings.$leftAligned.sink { leftAligned in
            NSLayoutConstraint.deactivate([leftAlignedConstraint, rightAlignedConstraint])
            if leftAligned {
                leftAlignedConstraint.isActive = true
            } else {
                rightAlignedConstraint.isActive = true
            }
            print(hostingController.view.intrinsicContentSize)
        }
        
        settings.invalidateIntrinsicContentSize = {
            print(hostingController.view.intrinsicContentSize)
            hostingController.view.invalidateIntrinsicContentSize()
        }
    }


}
