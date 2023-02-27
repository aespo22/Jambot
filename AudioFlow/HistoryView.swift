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
    let songs: [Song] = [
        Song(tags: "grinder back baby", creation: "2022", image: "testImage", mp3Link: "song1Link"),
        Song(tags: "wondering, crazy, beautiful", creation: "2021", image: "song2Image", mp3Link: "song2Link"),
        Song(tags: "bleeding, hard, dance", creation: "2020", image: "song3Image", mp3Link: "song3Link"),
        Song(tags: "trap dark remix", creation: "2020", image: "song3Image", mp3Link: "song3Link"),
        Song(tags: "upbeat loop big energy cap", creation: "2020", image: "song3Image", mp3Link: "song3Link"),
        // add more songs as needed
    ]
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                ScrollView(showsIndicators: false) {
                    Spacer().frame(height: 20)
                    ForEach(songs, id: \.tags) { song in
                        VStack {
                            HStack {
                                RandomColorView().cornerRadius(10)
                                VStack (alignment: .leading){
                                    Text(song.tags)
                                        .font(.headline)
                                    Text("Created in \(song.creation)")
                                        .font(.subheadline)
                                }.padding(.leading, 5)
                                Spacer()
                                Button(action: {
                                    // add code to play the song
                                }) {
                                    Image(systemName: "play.fill")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    Spacer()
                }
                .clipped()
                .navigationBarTitle("History")
                
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
                }.simultaneousGesture(TapGesture().onEnded {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                })
                
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    struct HistoryView_Previews: PreviewProvider {
        static var previews: some View {
            HistoryView()
        }
    }
}
