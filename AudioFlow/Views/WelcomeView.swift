//
//  WelcomeView.swift
//  MC3-Invisible
//
//  Created by Antonio Esposito on 21/02/23.
//

import SwiftUI
struct WelcomeView: View {
    var body: some View {
        NavigationView {
            HStack {
                VStack(alignment: .leading) {
                    NavigationLink(destination: exampleAPIUse().navigationBarBackButtonHidden(true)) {
                        Text("Create your first")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: exampleAPIUse().navigationBarBackButtonHidden(true)) {
                        Text("AI Generated")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: exampleAPIUse().navigationBarBackButtonHidden(true)) {
                        Text("song")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.black)
                .cornerRadius(8)
                
                NavigationLink(destination: exampleAPIUse().navigationBarBackButtonHidden(true)) {
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
        WelcomeView()
    }
}