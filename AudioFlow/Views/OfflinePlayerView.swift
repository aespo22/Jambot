import SwiftUI
import AVFoundation

struct OfflinePlayerView: View {
    
    let filePath: String
    let input: String
    let date: String
    
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    
    
    @State private var timer: Timer? = nil
    
    func formattedTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
         
        VStack {
            Text("Prompt:")
                .bold()
                .font(.title)
                .padding(.top, 50)
                .foregroundColor(.white)
            
            Spacer().frame(height: 10)
            
            Text(input)
                .font(.title3)
            
            Spacer().frame(height: 20)
            
            Text(date)
                .font(.footnote)
            Spacer()
            
            Button(action: togglePlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 75))
                    .padding()
                    .foregroundColor(.white) // Add foreground color modifier

            }
            
            if let duration = player?.duration {
                HStack {
                    Text("\(formattedTime(time: currentTime))")
                    Spacer()
                    Text("\(formattedTime(time: duration))")
                }
                .padding(.horizontal)
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                    if !editing {
                        player?.currentTime = currentTime
                    }
                })
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .background(MagicBg())
     
        .navigationBarItems(trailing:
            Button(action: shareFile) {
                Image(systemName: "square.and.arrow.up")
            }
        )
        .onAppear {
            do {
                let url = URL(fileURLWithPath: filePath)
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                duration = player?.duration ?? 0
                
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
        .onDisappear {
            if isPlaying {
                player?.pause()
                timer?.invalidate()
                timer = nil
            }
        }
    }

    func togglePlayPause() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        if let player = player {
            if isPlaying {
                player.pause()
                timer?.invalidate()
                timer = nil
            } else {
                player.play()
                startTimer()
            }
            isPlaying.toggle()
        }
    }
    
    func shareFile() {
        let fileURL = URL(fileURLWithPath: filePath)
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        if let player = player {
            if editingStarted {
                player.pause()
            } else {
                player.currentTime = currentTime
                player.play()
            }
            isPlaying = !editingStarted
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = player?.currentTime ?? 0
        }
    }
    
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


