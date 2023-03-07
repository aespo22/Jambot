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
    
    @State private var responseText = ""
    @State private var currentView: CurrentView = .inputView
    
    let networkMonitor = NetworkMonitor()
    @State private var showNoInternetAlert = false
    
    
    @FocusState private var textFieldIsFocused: Bool
    
    //to handle modal window closure
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var filesManager: FilesManager
    
    let tips = ["Do not reference existing songs", "Focus on genre, instruments, bpm, and vibe (dark, happy, etc...)", "Longer songs = longer loading times", "Have fun!"]
    
    let examples = ["Dark techno song melodic", "140bpm trap beat hard", "Dymphony rising in anticipation", "Morning relaxation calming"]
    
    @State private var showTips = false
    
    @State private var duration: Int = 60
    
    var body: some View {
        
        switch currentView {
        case .inputView:
            inputView
        case .magicScreen:
            MagicScreen()
                .task {
                    
                    let _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                        let currentLink = link
                        trackStatus(downloadLink: currentLink, pat: pat) { success in
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
            MusicPlayerView(officialLink: .constant(link), input: .constant(input), filesManager: filesManager)
            
        }
    }
    
    var inputView: some View {
        
        NavigationStack {
            VStack {
                

                Spacer()
                
                HStack(alignment: .center, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 8) {
                            if !input.isEmpty {
                                
                                ForEach(input.split(separator: " "), id: \.self) { word in
                                    Text(word)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.white)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .frame(height: 70)
                
                HStack {
                    Text("Create your song")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding(.horizontal, 20)
                
                
                
                TextField("Type in your keywords...", text: $input, axis: .vertical)
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
                
                Picker(selection: $duration, label: Text("Duration")) {
                    ForEach(30...300, id: \.self) { seconds in
                        Text("\(seconds) seconds")
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)
                
                
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
                
                Spacer()
                
            }
            .popover(isPresented: $showTips) {
                VStack {
                    Button(action: {showTips.toggle()}, label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .opacity(0.5)
                        
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(height: 20)
                    Text("Helpful Tips")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    List(tips, id: \.self) { tip in
                        
                        HStack {
                            Text(" ⚡️ ")
                            Text(tip)
                        }
                        
                        
                    }
                    .listStyle(.inset)
                    
                    Text("Examples")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    List(examples, id: \.self) { sentence in
                        
                        HStack {
                            Text(" 📖 ")
                            Text(sentence).italic()
                        }
                        
                    }
                    
                    .listStyle(.inset)
                    
                    
                }
                
                .padding()
            
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction ) {
                    
                    Button(action: {dismiss()}, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .opacity(0.5)
                        
                    })
                }
                
                ToolbarItem(placement: .confirmationAction ) {
                    
                    Button(action: {
                        showTips.toggle()
                    }, label: {
                        Image(systemName: showTips ? "questionmark.circle.fill" : "questionmark.circle")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .opacity(0.5)
                    })
                }
            }
            .alert(isPresented: $showNoInternetAlert) {
                Alert(
                    title: Text("nointernet"),
                    message: Text("jambnet"),
                    dismissButton: .default(Text("aight"))
                )
            }
            .navigationBarBackButtonHidden(true)
            
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
        exampleAPIUse(filesManager: FilesManager())
            .environment(\.locale, Locale.init(identifier: "eng"))
        exampleAPIUse(filesManager: FilesManager())
            .environment(\.locale, Locale.init(identifier: "kor"))
    }
}
