//
//  DashboardScreen.swift
//  iosApp
//
//  Created by Mohsin on 28/07/2025.
//  Copyright © 2025 orgName. All rights reserved.
//
import Foundation
import SwiftUICore
import SwiftUI
import Lottie
import Photos
import shared

struct DashboardScreen: View {
    @Binding var navPath: NavigationPath

    @EnvironmentObject var viewModelStoreOwner: IOSViewModelStoreOwner
    
    @EnvironmentObject var appContainer: ObservableValueWrapper<AppContainer>
        
    @State private var processor = PROCESSOR.enhance
    
    var body: some View {
        
        let photoEnhancerVm: PhotoEnhancerViewModel = viewModelStoreOwner.viewModel(
            factory: appContainer.value.photoEnhancerVMFactory
        )
        
            ZStack {
                Button(
                    "Add",
                    action: {
                    }
                ).buttonStyle(.bordered)
                // Background image, full-screen
                Image("ic_splash_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() // Covers entire screen, including behind toolbar
                
                // Content positioned below toolbar
                VStack(alignment: .leading) {
                    ZStack(alignment: .bottomLeading) {
                        FeatureMainLottie(fileName: "feature_main")
                        
                        VStack{
                            //  Spacer()
                            Image("ic_enhance_txt")
                                .frame(alignment: .bottom)
                                .padding(.bottom, 20)
                                .padding(.leading, 20)
                                .accessibilityLabel("Splash Image")
                        }
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 130)
                    .safeAreaPadding(.top)
                    .padding(.top, 80)
                    
                    Text("Photo Editor Tools")
                        .font(Font.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 30)
                    
               
                        ZStack(alignment: .leading){
                            Image("ic_enhance_bg")
                                .frame(maxWidth:.infinity)
                            
                            HStack(spacing: 8, content: {
                                Image("ic_enhance")
                                
                                Text("Image Enhance")
                                    .font(Font.custom("Poppins-Medium", size: 18))
                                    .foregroundColor(.white)
                            })
                            .padding(.leading, 30)
                            .frame(maxWidth: .infinity, alignment: Alignment.leading)
                            
                        }.onTapGesture {
                            navPath.append(Destination.processing(processor: .enhance))
                        }
                    
                    
                    
                    
             
                        ZStack(alignment: .leading){
                            Image("ic_bg_remove")
                                .frame(maxWidth:.infinity)
                                .padding(.top, 10)
                                .accessibilityLabel("Splash Image")
                            
                            HStack(spacing: 8, content: {
                                Image("ic_remove")
                                
                                Text("Background Remover")
                                    .font(Font.custom("Poppins-Medium", size: 18))
                                    .foregroundColor(.white)
                            })
                            .padding(.leading, 30)
                            .frame(maxWidth: .infinity, alignment: Alignment.leading)
                        }
                        .onTapGesture {
                            navPath.append(Destination.processing(processor: PROCESSOR.backgroundRemover))

                        }
                    
                
                    
                    Spacer() // Pushes content to the top
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Ai Photo")
                            .font(Font.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                        +
                        Text(" Editor")
                            .font(Font.custom("Poppins_Light", size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    
}


struct FeatureMainLottie: View {
    let fileName: String
    
    var body: some View {
        LottieView(animation: .named(fileName))
            .configure { animationView in
                animationView.contentMode = .scaleAspectFill
                animationView.loopMode = .loop
                animationView.play()
            }
            .frame(maxWidth: .infinity, maxHeight: 130) // Full width
            .background(Color.black.opacity(0.5)) // Background for rounded corners
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityLabel("Main Feature Animation")
        
    }
}
