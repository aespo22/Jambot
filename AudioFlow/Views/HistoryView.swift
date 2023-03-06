//
//  HistoryView.swift
//  AudioFlow
//
//  Created by Antonio Esposito on 27/02/23.
//
import SwiftUI

struct Song {
    let tags: String
    let creation: String
    let image: String
    let mp3Link: String
}



struct FileInfo: Identifiable, Hashable {
    let id = UUID()
    let input: String
    let date: String
    let path: URL
}


struct RandomColorView: View {
    
    var body: some View {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        let color = Color(red: red, green: green, blue: blue)
        
        Rectangle()
            .foregroundColor(color)
            .frame(width: 50, height: 50)
        
    }
}




struct HistoryView: View {
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let folderUrl: URL
    
    init() {
        folderUrl = documentsUrl.appendingPathComponent("mp3JamBotFiles")

    }
    
    @State private var showAlert = false
    @State private var selectedFile: FileInfo?
    @State private var showGenerateView: Bool = false
    
    
    @ObservedObject var filesManager = FilesManager()
    
    var body: some View {
        
        VStack (alignment: .leading) {
            NavigationStack {
                VStack{
                    
                    if filesManager.files.isEmpty {
                        VStack {
                            Spacer()
                            Text("No Songs Saved")
                                .font(.title)
                                .foregroundColor(.gray)
                            Spacer().frame(height: 10)
                            Text("Try adding a new song below!")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer().frame(height: 10)
                            
                            Image(systemName: "arrow.down")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            
                        }
                        
                    }
                    else {
                        List {
                            ForEach(filesManager.files.sorted(by: { $0.date > $1.date }), id: \.self) { file in
                                NavigationLink(destination: OfflinePlayerView(filePath: file.path.path, input: file.input, date: file.date)) {
                                    HStack{
                                        RandomColorView().cornerRadius(10)
                                        Spacer().frame(width: 10)
                                        VStack(alignment: .leading) {
                                            Text(file.input)
                                                .font(.headline)
                                                .lineLimit(1)
                                            Spacer().frame(height: 4)
                                            
                                            Text(file.date)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .foregroundColor(.primary)
                                }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        selectedFile = file
                                        showAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .contextMenu {
                                    ShareLink(item: URL(fileURLWithPath: file.path.path)).foregroundColor(.primary)
                                    
                                    
                                }
                            }
                            
                        }
                        .refreshable {
                            filesManager.refreshFiles()
                        }
                        .listStyle(PlainListStyle())
                        
                        
                    }
                    
                    
                    
                    
                    Spacer()
                    
                    Button {
                        showGenerateView = true
                    } label: {
                        ZStack {
                            Color(red: 199/255, green: 37/255, blue: 115/255, opacity: 1.0)
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Text("Generate Song")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                        .frame(height: 60)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    })
                    
                }
                .navigationBarTitle("History")
                .fullScreenCover(isPresented: $showGenerateView) {
                    exampleAPIUse(filesManager: filesManager)
                    
                }
                
                
            }
            .navigationBarBackButtonHidden(true)
            
            
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Confirm Deletion"), message: Text("Are you sure you want to delete this song?"), primaryButton: .destructive(Text("Delete")) {
                if let file = selectedFile {
                    filesManager.deleteFile(file)
                    filesManager.refreshFiles()
                    selectedFile = nil
                }
            }, secondaryButton: .cancel(Text("Cancel")))
        }
    }
    
    
    
    
    
    
    
    
    
    
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
