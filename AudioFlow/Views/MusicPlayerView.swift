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
    
    //for dismissing to history screen
    @Environment(\.dismiss) var dismiss
    
    
    @ObservedObject var filesManager: FilesManager
    
    @State var showSavedAlert = false
    
    
    let downloadManager = DownloadManager()
    

    
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                VStack {
                    
                    Text("promp")
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
                            .font(.system(size: 65))
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
                        
                        HStack {
                            Text("start")
                            Spacer()
                            Text("stop")
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
                    UIApplication.shared.isIdleTimerDisabled = false

                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                    
                    soundManager.pause()
                    
                }
                .onAppear{
                    UIApplication.shared.isIdleTimerDisabled = true

                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction ) {
                        
                        Button(action: {
                            dismiss()
                            
                        }, label: {

                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                                .font(.headline)
                        })
                        
                    }
                    
                    ToolbarItem(placement: .confirmationAction ) {
                        
                        Text(saveText)
                            .foregroundColor(.primary)
                            .onTapGesture {
                                saveText = "Saving song..."
                                
                                downloadManager.saveMp3ToPhone(input: input, url: URL(string: officialLink)!) {
                                    // this code will be executed only when the saveMp3ToPhone function is done
                                    filesManager.refreshFiles()
                                    self.showSavedAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                        self.showSavedAlert = false
                                    }
                                    saveText = "Saved"
                                }
                                
                            }
                        
                    }
                    
                }
                if showSavedAlert {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Color.black)
                        .frame(width: 250, height: 250)
                        .overlay(
                            VStack {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                                    .font(.largeTitle)
                                Spacer().frame(height: 10)
                                
                                Text("songsav")
                                    .font(.largeTitle)
                                    .bold()
                                Spacer().frame(height: 10)
                                Text("playitanytime")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        ).opacity(0.95)
                    
                }
            }
        }
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
        MusicPlayerView(officialLink: .constant("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"), input: .constant("hello grinder baby back baby back wayyyy I think this does not work anymoreeee baby yearhhhss"), filesManager: FilesManager())
            .environment(\.locale, Locale.init(identifier: "eng"))
        MusicPlayerView(officialLink: .constant("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"), input: .constant("hello grinder baby back baby back wayyyy I think this does not work anymoreeee baby yearhhhss"), filesManager: FilesManager())
            .environment(\.locale, Locale.init(identifier: "kor"))
    }
}


