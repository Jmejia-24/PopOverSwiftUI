//
//  PopOver.swift
//
//  Created by Byron Mejia on 5/24/22.
//

import SwiftUI

struct PopOver: View {
    @State var open = false
    @State var popoverSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        WithPopover(
            showPopover: $open,
            popoverSize: popoverSize, arrowDirections: [.down, .up, .right, .left],
            content: {
                Button("Tap me") {
                    self.open.toggle()
                }
            },
            popoverContent: {
                VStack {
                    Button("Increase size") {
                        self.popoverSize = CGSize(width: 300, height: 600)
                    }
                    Button("Close") {
                        self.open = false

                    }
                }
            })
    }
}

struct PopOver_Previews: PreviewProvider {
    static var previews: some View {
        PopOver()
    }
}

struct WithPopover<Content: View, PopoverContent: View>: View {
    
    @Binding var showPopover: Bool
    var popoverSize: CGSize? = nil
    var arrowDirections: UIPopoverArrowDirection = [.down]
    let content: () -> Content
    let popoverContent: () -> PopoverContent
    
    var body: some View {
        content()
            .background(
                Wrapper(showPopover: $showPopover, arrowDirections: arrowDirections, popoverSize: popoverSize, popoverContent: popoverContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
    }
    
    struct Wrapper<PopoverContent: View> : UIViewControllerRepresentable {
        
        @Binding var showPopover: Bool
        var arrowDirections: UIPopoverArrowDirection
        let popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) -> WrapperViewController<PopoverContent> {
            return WrapperViewController(
                popoverSize: popoverSize,
                permittedArrowDirections: arrowDirections,
                popoverContent: popoverContent) {
                    self.showPopover = false
                }
        }
        
        func updateUIViewController(_ uiViewController: WrapperViewController<PopoverContent>, context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) {
            uiViewController.updateSize(popoverSize)
            showPopover ? uiViewController.showPopover() : uiViewController.hidePopover()
        }
    }
    
    class WrapperViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {
        
        var popoverSize: CGSize?
        let permittedArrowDirections: UIPopoverArrowDirection
        let popoverContent: () -> PopoverContent
        let onDismiss: () -> Void

        var popoverVC: UIViewController?
        
        required init?(coder: NSCoder) { fatalError("") }
        init(popoverSize: CGSize?,
             permittedArrowDirections: UIPopoverArrowDirection,
             popoverContent: @escaping () -> PopoverContent,
             onDismiss: @escaping() -> Void) {
            self.popoverSize = popoverSize
            self.permittedArrowDirections = permittedArrowDirections
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            super.init(nibName: nil, bundle: nil)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            .none
        }
        
        func showPopover() {
            guard popoverVC == nil else { return }
            let vc = UIHostingController(rootView: popoverContent())
            if let size = popoverSize { vc.preferredContentSize = size }
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            if let popover = vc.popoverPresentationController {
                popover.sourceView = view
                popover.permittedArrowDirections = self.permittedArrowDirections
                popover.delegate = self
            }
            popoverVC = vc
            self.present(vc, animated: true, completion: nil)
        }
        
        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }
        
        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }
    }
}
