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
        
        
        // Check if the flag is set
        let defaults = UserDefaults.standard
        let hasShownBoardView = defaults.bool(forKey: "hasShownBoardView")
        
        if !hasShownBoardView {
            // Show the board view and set the flag
            defaults.set(true, forKey: "hasShownBoardView")
            let exampleAPIUse = WelcomeView(filesManager: FilesManager())
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: exampleAPIUse)
                self.window = window
                window.makeKeyAndVisible()
            }
        } else {
            // Show the app's main view
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
                    NavigationLink(destination: HistoryView().navigationBarBackButtonHidden(true)) {
                        Text("create")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: HistoryView().navigationBarBackButtonHidden(true)) {
                        Text("aigen")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: HistoryView().navigationBarBackButtonHidden(true)) {
                        Text("song")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.black)
                .cornerRadius(8)
                
                NavigationLink(destination: HistoryView().navigationBarBackButtonHidden(true)) {
                    Image(systemName: "arrow.forward.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                }
            }
            .padding()
        }
    }
    private func navigateToHistoryView() {
        // Set the flag to indicate that the boarding view has been shown
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "hasShownBoardView")
        
        // Navigate to the HistoryView
        let historyView = HistoryView()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: historyView)
            window.makeKeyAndVisible()

        }
       
    }
    
    
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(filesManager: FilesManager())
            .environment(\.locale, Locale.init(identifier: "eng"))
        WelcomeView(filesManager: FilesManager())
            .environment(\.locale, Locale.init(identifier: "kor"))
    }
}
