//
//  TestPage1.swift
//  SwiftUIInteropTestApp
//
//  Created by Lukas Capkovic on 3/27/22.
//

import SwiftUI
import Combine

struct TestPage2: View {
    @StateObject fileprivate var settings = TestViewSettings()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SwiftUI in UIKit - sized by Auto Layout")
                .font(.system(size: 32))
            MainVCRepresentable()
                .environmentObject(settings)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary, lineWidth: 4)
                )
                .background(alignment: .topLeading) {
                    Text("UIKit")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                        .padding(20)
                }
            settingsView
        }.padding(40)
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
                    Slider(value: $settings.width, in: 0...300)
                    Text("\(Int(settings.width))pt")
                        .frame(width:50, alignment: .trailing)
                }
                .frame(maxWidth: 300)
            }
            HStack {
                Text("Target width")
                Spacer()
                HStack {
                    Slider(value: $settings.targetWidth, in: 0...300)
                    Text("\(Int(settings.targetWidth))pt")
                        .frame(width:50, alignment: .trailing)
                }
            }.padding([.top], 50)
            HStack {
                Spacer()
                Button(action: {
                    settings.animateToTarget?()
                }, label: {
                    Text("Animate to target width")
                    
                })
                .buttonStyle(.bordered)
            }
            HStack {
                Spacer()
                Button(action: {
                    settings.width = settings.targetWidth
                }, label: {
                    Text("Jump to target width")
                    
                })
                .buttonStyle(.bordered)
            }
        }.frame(width: 400)
    }
}

private class TestViewSettings: ObservableObject {
    @Published var width: CGFloat = 200
    @Published var targetWidth: CGFloat = 200
    @Published var leftAligned: Bool = false
    
    var animateToTarget: (() -> ())?
}

private struct MainVCRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var settings: TestViewSettings
    
    func makeUIViewController(context: Context) -> TestVC {
        return TestVC(settings: settings)
    }
    
    func updateUIViewController(_ uiViewController: TestVC, context: Context) {}
    
    typealias UIViewControllerType = TestVC
    
    
}

private class TestVC: UIViewController {
    var alignmentObserver: AnyCancellable?
    var widthObserver: AnyCancellable?
    private let settings: TestViewSettings

    init(settings: TestViewSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = CustomHostingController(rootView: FlexibleView())
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let leftAlignedConstraint = hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let rightAlignedConstraint = hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let widthConstraint = hostingController.view.widthAnchor.constraint(equalToConstant: settings.width)
        
        widthConstraint.isActive = true
        
        alignmentObserver = settings.$leftAligned.sink { leftAligned in
            NSLayoutConstraint.deactivate([leftAlignedConstraint, rightAlignedConstraint])
            if leftAligned {
                leftAlignedConstraint.isActive = true
            } else {
                rightAlignedConstraint.isActive = true
            }
        }
        
        widthObserver = settings.$width.sink { width in
            widthConstraint.constant = width
        }
        
        settings.animateToTarget = {
            UIView.animate(withDuration: 0.3) {
                withAnimation {
                    self.settings.width = self.settings.targetWidth
                }
                self.view.layoutIfNeeded()
            }
        }
    }
}

struct FlexibleView: View {
        
    var body: some View {
        Rectangle()
            .foregroundColor(.indigo)
            .overlay {
                Text("SwiftUI View")
            }
//            .overlay {
//                GeometryReader() { proxy in
//                    Rectangle()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(proxy.size.width > 100 ? (proxy.size.width > 200 ? .green : .orange) : .blue)
//                }
//            }
            

    }
}
