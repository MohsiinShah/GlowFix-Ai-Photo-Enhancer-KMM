//
// Created by Mohsin on 26/07/2025.
// Copyright (c) 2025 orgName. All rights reserved.
//

import Foundation
import SwiftUICore
import SwiftUI
import shared
import Lottie

struct SplashScreen: View {
    
    @State var navPath = NavigationPath()
    @EnvironmentObject var viewModelStoreOwner: IOSViewModelStoreOwner
    /// Injects the `AppContainer` from the environment, providing access to application-wide dependencies.
    @EnvironmentObject var appContainer: ObservableValueWrapper<AppContainer>
    
    @State private var navigateToContentView = false
    
    let mColorDullWhite = Color("DullWhite")
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                Image("ic_splash_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    LottieAnimationView(filename: "anim_splash", loopMode: .loop)
                    
                    Image("ic_splash")
                        .padding(.leading, 10)
                    
                    VStack(alignment: .leading) {
                        
                        Text("Ai Photo")
                            .font(Font.custom("Poppins-Bold", size: 24)) // Use PostScript name
                            .foregroundColor(.white)
                        
                        + Text(" Editor")
                            .font(Font.custom("Poppins_Light", size: 24))
                            .foregroundColor(.white)
                        
                        
                        Text("Enhance your product photos effortlessly with Ai backgrounds. Create polished product shots")
                            .font(Font.custom("Poppins-Regular", size: 15)) // Use PostScript name
                            .foregroundColor(mColorDullWhite)
                        
                        
                            ZStack {
                                Image("ic_get_started")
                                HStack(alignment: .center){
                                    Text("Get Started")
                                        .font(Font.custom("Poppins-Medium", size: 13))
                                        .foregroundColor(.white)
                                }
                                
                            }.padding(.top, 30)
                            .onTapGesture {
                                navPath.append(
                                    Destination.dashboard
                                )
                            }
                            
                        
                        Spacer() // ✅ Pushes content to the top
                    }
                    .padding(.leading, 20)
                }
                .navigationDestination(for: Destination.self) { destination in
                                 switch destination {
                                
                                 case .filters(let path, let processor):
                                     FiltersScreen(navPath: $navPath, path: path, selectedProcessor: processor)
                                 case .result(let path, let processor):
                                     ResultScreen(navPath: $navPath, processor: processor, path: path)
                                 case .dashboard:
                                     DashboardScreen(navPath: $navPath).navigationBarBackButtonHidden()
                                 case .gallery(processor: let processor):
                                     GalleryScreen(navPath: $navPath, processor: processor)
                                 case .processing(processor: let processor):
                                     ProcessingScreen(navPath: $navPath, processor: processor)
                                     
                                 }
                             }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct LottieAnimationView: View {
    let filename: String
    let loopMode: LottieLoopMode
    
    var body: some View {
        LottieView(animation: .named(filename))
            .configure { animationView in
                animationView.contentMode = .scaleAspectFit
                animationView.loopMode = loopMode
                animationView.play()
            }
            .frame(height: UIScreen.main.bounds.height * 0.5)
    }
}
