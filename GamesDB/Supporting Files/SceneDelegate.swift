//
//  SceneDelegate.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let disposeBag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        NetworkManager.shared.configure()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.setupRootViewController()
                },
                onError: { [weak self] error in
                    self?.showConfigurationError(error)
                    self?.setupRootViewController()
                }
            )
            .disposed(by: disposeBag)
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NetworkManager.shared.configure()
            .subscribe(
                onCompleted: {
                    print("NetworkManager configured successfully")
                },
                onError: { [weak self] error in
                    self?.showConfigurationError(error)
                    print(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func setupRootViewController() {
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.viewControllers = [DiscoverViewController(viewModel: DiscoverViewModel())]
        window?.rootViewController = navigationController
    }
    
    private func showConfigurationError(_ error: Error) {
        let alert = UIAlertController(title: String(localized: "Connection Error"), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK"), style: .default))
        window?.rootViewController?.present(alert, animated: true)
    }
}

