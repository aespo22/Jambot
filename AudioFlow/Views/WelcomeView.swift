//
//  WelcomeView.swift
//  MC3-Invisible
//
//  Created by Antonio Esposito on 21/02/23.
//
import SwiftUI
import UIKit
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let defaults = UserDefaults.standard
        let hasShownBoardView = defaults.bool(forKey: "hasShownBoardView")
        
        if !hasShownBoardView {
            defaults.set(true, forKey: "hasShownBoardView")
            let exampleAPIUse = WelcomeView(filesManager: FilesManager())
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: exampleAPIUse)
                self.window = window
                window.makeKeyAndVisible()
            }
        } else {
            let contentView = HistoryView()
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: contentView)
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }
}

struct WelcomeView: View {
    @ObservedObject var filesManager: FilesManager
    
    var body: some View {
        NavigationView {
            HStack {
                VStack(alignment: .leading) {
                    NavigationLink(destination: exampleAPIUse(filesManager: filesManager).navigationBarBackButtonHidden(true)) {
                        Text("Create your first")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: exampleAPIUse(filesManager: filesManager).navigationBarBackButtonHidden(true)) {
                        Text("AI Generated")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: exampleAPIUse(filesManager: filesManager).navigationBarBackButtonHidden(true)) {
                        Text("song")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.black)
                .cornerRadius(8)
                
                NavigationLink(destination: exampleAPIUse(filesManager: filesManager).navigationBarBackButtonHidden(true)) {
                    Image(systemName: "arrow.forward.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                }
            }
            .padding()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(filesManager: FilesManager())
    }
}
