//
//  MusicPlayerView.swift
//  AudioFlow
//
//  Created by Antonio Esposito on 27/02/23.
//

import SwiftUI
import AVFoundation

class SoundManager: ObservableObject {
    
    
    
    
    
    init(){
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var audioPlayer: AVPlayer?
    var timeObserverToken: Any?
    @Published var currentTime: Double = 0.0
    var pauseTime: Double = 0.0
    
    func playSound(sound: String) {
        if let url = URL(string: sound) {
            self.audioPlayer = AVPlayer(url: url)
        }
    }
    
    func getDuration() -> Double? {
        return audioPlayer?.currentItem?.asset.duration.seconds
    }
    
    func startUpdatingCurrentTime(progressHandler: ((Double) -> Void)?) {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            progressHandler?(time.seconds)
        }
    }
    
    
    func pause() {
        pauseTime = currentTime
        audioPlayer?.pause()
    }
    
    func play() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        
        if let duration = getDuration() {
            let remainingTime = duration - pauseTime
            seekTo(time: pauseTime)
            audioPlayer?.play()
            startUpdatingCurrentTime(progressHandler: { [weak self] currentTime in
                guard let self = self else { return }
                self.currentTime = currentTime + self.pauseTime
                if self.currentTime >= duration {
                    self.pauseTime = 0
                    self.currentTime = 0
                    self.pause()
                }
            })
        }
    }
    
    func seekTo(time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        audioPlayer?.seek(to: targetTime)
    }
}

struct MusicPlayerView: View {
    @State var isPlaying = false
    @State var currentTime: Double = 0.0
    @State var saveText: String = "Save"
    @StateObject private var soundManager = SoundManager()
    
    @Binding var officialLink: String
    @Binding var input: String
    
    
    let downloadManager = DownloadManager()
    
    
    var body: some View {
        
        
        
        
        
        VStack {
            Text("Prompt:")
                .bold()
                .font(.title3)
                .padding(.top, 50)
                .foregroundColor(.white)
            
            
            Spacer().frame(height: 10)
            
            HStack {
                Text(input)
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                
            }.padding(.horizontal, 50)
            
            Spacer().frame(height: 20)
            
            //            Text(date)
            //                .font(.footnote)
            
            
            
            Spacer()
            
            Button(action: {
                if isPlaying {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    soundManager.pause()
                } else {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    soundManager.playSound(sound: officialLink)
                    soundManager.startUpdatingCurrentTime(progressHandler: { currentTime in
                        self.currentTime = currentTime
                    })
                    soundManager.play()
                }
                isPlaying.toggle()
                
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 75))
                    .padding()
                    .foregroundColor(.white)
                
            }
            
            
            if let duration = soundManager.getDuration() {
                HStack {
                    Text("\(formattedTime(time: currentTime))")
                    Spacer()
                    Text("\(formattedTime(time: duration))")
                }
                .padding(.horizontal)
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                    if !editing {
                        soundManager.seekTo(time: currentTime)
                    }
                })
                .padding(.horizontal, 40)
            }else{
                //                    this is purely so that elements don't move around
                HStack {
                    Text("Start")
                    Spacer()
                    Text("End")
                }
                .padding(.horizontal)
                Slider(value: $currentTime, in: 0...0)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .background(MagicBg())
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
            
            soundManager.pause()
            
        }.navigationBarItems(
            leading: NavigationLink(destination: HistoryView()) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                
            },
            
            
            trailing: NavigationLink(destination: HistoryView()) {
                Text(saveText)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        saveText = "Saved!"
                        downloadManager.saveMp3ToPhone(input: input, url: URL(string: officialLink)!)
                    }
            }
            
        )
        
        
    }
    
    private func formattedTime(time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: date)
    }
}





struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView(officialLink: .constant("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"), input: .constant("hello grinder baby back baby back wayyyy I think this does not work anymoreeee baby yearhhhss"))
    }
}

