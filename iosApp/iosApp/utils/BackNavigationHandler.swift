import SwiftUI
import UIKit

struct BackNavigationHandler: UIViewControllerRepresentable {
    var onBack: () -> Bool  // Return true to allow back, false to cancel
    
    func makeUIViewController(context: Context) -> BackHandlerViewController {
        let vc = BackHandlerViewController()
        vc.onBack = onBack
        return vc
    }
    
    func updateUIViewController(_ uiViewController: BackHandlerViewController, context: Context) {}
}

class BackHandlerViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var onBack: (() -> Bool)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return onBack?() ?? true
    }

    func navigationController(_ navigationController: UINavigationController, shouldPop viewController: UIViewController) -> Bool {
        let shouldPop = onBack?() ?? true
        if !shouldPop {
            // Cancel pop
            navigationController.setViewControllers(navigationController.viewControllers, animated: false)
        }
        return shouldPop
    }
}

