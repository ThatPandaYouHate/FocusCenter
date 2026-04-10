import SwiftUI
import UIKit

extension View {
    func disableInteractivePopGesture() -> some View {
        background(InteractivePopGestureDisabler())
    }
}

private struct InteractivePopGestureDisabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        InteractivePopTokenViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private final class PopGestureBlocker: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}

private final class InteractivePopTokenViewController: UIViewController {
    private let popBlocker = PopGestureBlocker()
    private weak var savedPopDelegate: UIGestureRecognizerDelegate?
    private weak var blockedNavigationController: UINavigationController?
    private var didInstallPopBlock = false
    private var savedPopGestureEnabled = true

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent != nil {
            installPopGestureBlockIfNeeded()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        installPopGestureBlockIfNeeded()
        DispatchQueue.main.async { [weak self] in
            self?.installPopGestureBlockIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.installPopGestureBlockIfNeeded()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePopGestureBlockIfNeeded()
    }

    private func owningNavigationController() -> UINavigationController? {
        var current: UIViewController? = self
        for _ in 0..<24 {
            guard let c = current else { break }
            if let nav = c as? UINavigationController { return nav }
            if let nav = c.navigationController { return nav }
            current = c.parent
        }

        guard let root = keyWindowRootViewController() else { return nil }
        return findNavigationController(in: root)
    }

    private func keyWindowRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }

    private func findNavigationController(in vc: UIViewController) -> UINavigationController? {
        if let nav = vc as? UINavigationController { return nav }
        for child in vc.children {
            if let found = findNavigationController(in: child) { return found }
        }
        if let presented = vc.presentedViewController {
            return findNavigationController(in: presented)
        }
        return nil
    }

    private func installPopGestureBlockIfNeeded() {
        guard !didInstallPopBlock,
              let nav = owningNavigationController(),
              let pop = nav.interactivePopGestureRecognizer else { return }
        savedPopDelegate = pop.delegate
        savedPopGestureEnabled = pop.isEnabled
        pop.delegate = popBlocker
        pop.isEnabled = false
        blockedNavigationController = nav
        didInstallPopBlock = true
    }

    private func removePopGestureBlockIfNeeded() {
        guard didInstallPopBlock else { return }
        let nav = blockedNavigationController ?? owningNavigationController()
        if let pop = nav?.interactivePopGestureRecognizer {
            pop.delegate = savedPopDelegate
            pop.isEnabled = savedPopGestureEnabled
        }
        savedPopDelegate = nil
        blockedNavigationController = nil
        didInstallPopBlock = false
    }
}
