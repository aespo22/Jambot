
//  MagicScreen.swift
//  MC3-Invisible
//
//  Created by Maura De Chiara  on 20/02/23.
//
import SwiftUI



struct MagicScreen: View {
    @State private var colors = [Color.purple, Color.pink, Color.yellow, Color.mint]
    let gradient = Gradient(colors: [Color.purple,Color.blue, Color.yellow, Color.mint])
    
    @State private var isLoading = false
    
    var delay: Double = 0 // 1. << don't use state for injectable property
    
    @State private var scale: CGFloat = 0.5
    

    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ForEach(colors.indices, id: \.self) { index in
                Circle()
                    .fill(getGradient(color: colors[index]))
                    .animation(Animation.linear(duration: 8).repeatForever(autoreverses: true), value: colors)
                    .frame(width: 800, height: 800)
                    .offset(x: CGFloat.random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: -UIScreen.main.bounds.height...UIScreen.main.bounds.height))
                    .blur(radius: 20)
            }
            
            
            
            
            VStack {
                
                
                HStack (alignment: .bottom) {
                    
                    Text("Making some magic")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer().frame(width: 4)
                    
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 7, height: 7)
                                .foregroundColor(Color.white)
                                .scaleEffect(scale)
                                .animation(
                                    Animation.easeInOut(duration: 1)
                                        .repeatForever().delay(delay), value: scale
                                )
                                .onAppear {
                                    self.scale = 1
                                }
                            
                            Spacer().frame(width: 1)
                            
                            Circle()
                                .frame(width: 7, height: 7)
                                .foregroundColor(Color.white)
                                .scaleEffect(scale)
                                .animation(
                                    Animation.easeInOut(duration: 2)
                                        .repeatForever().delay(delay), value: scale
                                )
                                .onAppear {
                                    self.scale = 1
                                }
                            Spacer().frame(width: 3)
                            Circle()
                                .frame(width: 7, height: 7)
                                .foregroundColor(Color.white)
                                .scaleEffect(scale)
                                .animation(
                                    Animation.easeInOut(duration: 3)
                                        .repeatForever().delay(delay), value: scale
                                )
                                .onAppear {
                                    self.scale = 1
                                }
                            
                        }
                        Spacer().frame(height: 6)
                    }
                    
                    
                }
                
                
                
            }
            
            
            
            
            
            
            
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true

            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                withAnimation(Animation.linear(duration: 10)) {
                    self.colors = [self.colors[1], self.getNewColor()]
                    
                }
                
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func getGradient(color: Color) -> LinearGradient {
        let start = Color.white.opacity(0.05)
        let end = Color.white.opacity(0.05)
        
        return LinearGradient(gradient: Gradient(colors: [start, color.opacity(1), end]), startPoint: .top, endPoint: .bottom)
    }
    
    func getNewColor() -> Color {
        let hue = Double.random(in: 5...10)
        let saturation = Double.random(in: 5...10)
        let brightness = Double.random(in: 5...10)
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}






struct MagicScreen_Previews: PreviewProvider {
    static var previews: some View {
        MagicScreen()
    }
}
