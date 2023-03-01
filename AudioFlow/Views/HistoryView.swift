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



struct FileInfo: Identifiable {
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
    
    var body: some View {
        
        VStack (alignment: .leading) {
                NavigationView {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 20)
                        List {
                            ForEach(getFiles()) { file in
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
                            }
                            
                        }
                        .listStyle(PlainListStyle())


                        
                        Spacer()
                        NavigationLink(destination: exampleAPIUse()) {
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .cornerRadius(12)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        })
                        Spacer()
                    }
                    .navigationBarTitle("History")


                }
                .navigationBarBackButtonHidden(true)

            
        } .alert(isPresented: $showAlert) {
            Alert(title: Text("Confirm Deletion"), message: Text("Are you sure you want to delete this file?"), primaryButton: .destructive(Text("Delete")) {
                if let file = selectedFile {
                    deleteFile(file)
                    selectedFile = nil
                }
            }, secondaryButton: .cancel(Text("Cancel")))
        }
    }
    
    func deleteFile(_ file: FileInfo) {
            do {
                try FileManager.default.removeItem(at: file.path)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    
    
    func getFiles() -> [FileInfo] {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryUrl = documentsUrl.appendingPathComponent("mp3JamBotFiles")
        
        var fileInfos: [FileInfo] = []
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
            for file in files {
                if file.lastPathComponent.starts(with: ".DS_Store") {
                    continue // Ignore .DS_Store file
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
                let filename = file.lastPathComponent
                if let date = dateFormatter.date(from: String(filename.prefix(16))) {
                    let input = String(filename.dropFirst(17).dropLast(4)).replacingOccurrences(of: "-", with: " ")
                    fileInfos.append(FileInfo(input: input, date: formatDate(date), path: file))
                } else {
                    fatalError("Error parsing date from file name: \(filename)")
                }
            }
        } catch {
            print(error)
        }
        
        return fileInfos
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    
}
