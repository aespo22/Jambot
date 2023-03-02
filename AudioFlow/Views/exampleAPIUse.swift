//
//  exampleAPIUse.swift
//  AudioFlow
//
//  Created by Antonio Esposito on 27/02/23.
//
import SwiftUI



struct exampleAPIUse: View {
    
    
   
    
    
        let api = trackGenerationAPI()
    @State private var input = ""
    @State private var link = ""
    
    let pat = "YW50b25pb19hbmRfZnJpZW5kcy4xODU1MTA5Ny5lMWQwODBkNjQ5M2EyZmNkZGE3Yjg3ZjEyYjE4YTdiZmU4OWM1NGQ1LjEuMw.b952a32df79024eadc42b52091ae06a28e403a256abf0a6a3fe9538a6181842a"
    let duration = 60
    
    @State private var responseText = ""
    @State private var currentView: CurrentView = .inputView
    
    let networkMonitor = NetworkMonitor()
    @State private var showNoInternetAlert = false

    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        
        switch currentView {
        case .inputView:
            inputView
        case .magicScreen:
            MagicScreen()
                .task {
                    let _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                        trackStatus(downloadLink: link, pat: pat) { success in
                            if success {
                                timer.invalidate()
                                DispatchQueue.main.async {
                                    currentView = .player
                                }
                            }
                        }
                    }
                }
        case .player:
            MusicPlayerView(officialLink: .constant(link), input: .constant(input))
            
            
        }
    }
    
    var inputView: some View {
        
        VStack {
            HStack {
                Spacer().frame(width: 20)
                Text("Create your song:")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer().frame(height: 30)
            
            TextField("Type your song description", text: $input, axis: .vertical)
                .focused($textFieldIsFocused)
                .onAppear {
                    self.textFieldIsFocused = true
                  
                }
                .frame(height: 48)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 50))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 2.0)
                )
                .lineLimit(2, reservesSpace: true)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .overlay(
                    HStack {
                        Spacer()
                        if !input.isEmpty {
                            Button(action: {
                                input = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 40)
                        }
                    },
                    alignment: .trailing
                )

            
            Spacer().frame(height: 16)
            
            HStack {
                if !input.isEmpty {
                    
                    Button(action: {
                        
                        
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)


                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        
                        
                        
                        if networkMonitor.isConnected {
                            currentView = .magicScreen

                            api.generateTrack(input: input, pat: pat, duration: duration) { result in
                                switch result {
                                case .success(let response):
                                    let tasks = response.data.tasks
                                    guard !tasks.isEmpty else { return }
                                    self.responseText = tasks[0].downloadLink.absoluteURL.absoluteString
                                    NSLog("!!! INPUT: "+input)
                                    NSLog("!!! Status: "+String(tasks[0].taskStatusCode))
                                    self.link = String(self.responseText)
                                    NSLog("!!! LINK: "+self.link)
                                case .failure(let error):
                                    currentView = .inputView

                                    self.responseText = error.localizedDescription
                                }
                            }
                            
                        } else {
                            
                            showNoInternetAlert = true

                        }
                        
                        
                        


                    }, label: {
                        HStack {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .foregroundColor(.black)
                            
                            
                            
                        }
                        .padding(.horizontal, 160)
                        .padding(.vertical, 20)
                        .background(.white)
                        .opacity(1)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    })//end button
                    
                    
                }else{
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .foregroundColor(.black)
                            
                            
                        }
                        .padding(.horizontal, 160)
                        .padding(.vertical, 20)
                        .background(.white)
                        .opacity(0.2)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    })//end button
                    .disabled(true)
                    
                    
                    
                    
                }
                
            }.padding(.horizontal, 20)
            
            //            Text(responseText)
            //                .padding()
        }.alert(isPresented: $showNoInternetAlert) {
            Alert(
                title: Text("No internet connection available"),
                message: Text("JamBot is really cool, but you need an internet connection :/"),
                dismissButton: .default(Text("OK"))
            )
        }

    }
}

enum CurrentView {
    case inputView
    case magicScreen
    case player
}

struct API_Previews: PreviewProvider {
    static var previews: some View {
        exampleAPIUse()
    }
}
