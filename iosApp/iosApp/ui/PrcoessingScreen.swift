//
//  PrcoessingScreen.swift
//  iosApp
//
//  Created by Mohsin on 28/07/2025.
//  Copyright © 2025 orgName. All rights reserved.
//

import SwiftUI
import shared
import UIKit
import PhotosUI

struct ProcessingScreen: View{
    @Binding var navPath: NavigationPath
    
    let processor: PROCESSOR

    @EnvironmentObject var viewModelStoreOwner: IOSViewModelStoreOwner
    
    @EnvironmentObject var appContainer: ObservableValueWrapper<AppContainer>
    
    @Environment(\.dismiss) private var dismiss

    let mColorDullWhite = Color("DividerColor")
    
    let mBlackTwentyPercent = Color("BlackTen")
    
    @State private var navigateToResult = false
    
    @State private var enhancedFilePath = ""
    
    @State private var isProcessingGoingOn = false
    
    @State private var selectedImage: UIImage? = nil
    
   @State private var selectedItem: PhotosPickerItem? = nil
    
    @State private var platformImage: PlatformImage? = nil
    
    @State private var isPickerPresented = false
    
    @State private var noImageSelectionAlert = false

    var body: some View{
        
        let photoEnhancerVm: PhotoEnhancerViewModel = viewModelStoreOwner.viewModel(
            factory: appContainer.value.photoEnhancerVMFactory
        )
        
        let title = if processor == PROCESSOR.enhance {"Ai Enhance"} else {"Ai Remove"}
        
        let btnTitle = if processor == PROCESSOR.enhance {"Enhance"} else {"Remove Background"}
                
        Observing(photoEnhancerVm.processingState){ state in
                        
            ZStack {
                Image("ic_splash_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                
                VStack{
                    
                    ZStack {
                        mBlackTwentyPercent // background color of the box
                        
                        switch state{
                        case let state as ProcessingState.Success:
                            EmptyView()
                        default:
                            
                            if let selectedImage{
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipped()
                                    .padding()
                            }else{
                            
                                ZStack{
                                    SelectPhotoButton(selectedItem: $selectedItem, selectedImage: $selectedImage,
                                                      platformImage: $platformImage)
                                }
                                .frame(height: UIScreen.main.bounds.height * 0.7)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            Color.gray, // Border color
                                            style: StrokeStyle(lineWidth: 2, dash: [8]) // dash length 8
                                        )
                                )
                                
                            }
                    
                        }
                        
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    
                    Spacer()
                    
                    ZStack {
                        Image("ic_get_started")
                        HStack(alignment: .center){
                            
                            Text(btnTitle)
                                .font(Font.custom("Poppins-Medium", size: 13))
                                .foregroundColor(.white)
                            
                        }
                        
                    }.padding(.bottom , 30)
                        .onTapGesture {
                        
                            noImageSelectionAlert = selectedImage == nil

                            if !(state is ProcessingState.Processing) {
                                if let platformImage{
                                    photoEnhancerVm.enhanceImage(platformImage: platformImage, processor: processor)
                                }
                            }
                        }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
                
                
                if(state is ProcessingState.Processing){
                    ZStack{
                        ProcessingAnimation(
                            isProcessing: true,
                            headingOne: "Processing Your Request",
                            headingTwo: "Please wait a moment"
                        )
                        
                    }
                }
                
            }
            .onChange(of: state) { _, newState in
                
                if let successState = newState as? ProcessingState.Success {
                    if processor == PROCESSOR.enhance {
                        navPath.append(Destination.filters(path: successState.file?.path ?? "", processor: processor))
                    } else {
                
                        navPath.append(Destination.result(path: successState.file?.path ?? "", processor: processor))
                    }
                }
                
                if newState is ProcessingState.Processing {
                    isProcessingGoingOn = true
                                    disableSwipeBack()
                                } else {
                                    isProcessingGoingOn = false
                                    enableSwipeBack()
                                }
            }
            .onAppear {
                // Ensure state is checked when the view appears
                navigateToResult = photoEnhancerVm.processingState.value is ProcessingState.Success
            }
        }.toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(title)
                        .font(Font.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if !(isProcessingGoingOn) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
            
        }
        .alert("Please select a file", isPresented: $noImageSelectionAlert) {
            Button("OK", role: .cancel) { }
        }
        .onDisappear{
            photoEnhancerVm.clearState()
            enableSwipeBack()
        }
        .navigationBarBackButtonHidden(true)
    }
}

private func disableSwipeBack() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController as? UINavigationController {
            rootViewController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    private func enableSwipeBack() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController as? UINavigationController {
            rootViewController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }


struct ProcessingAnimation: View {
    let isProcessing: Bool
    let headingOne: String
    let headingTwo: String
    
    @State private var orbitRotation: Double = 0
    @State private var corePulse: CGFloat = 1.0
    @State private var holographicSweep: CGFloat = 0.0
    @State private var ambientGlow: Double = 0.3
    
    var body: some View {
        Group {
            if isProcessing {
                ZStack {
                    backgroundGradient
                    ambientGlowOverlay
                    orbitalParticles
                    coreAndText
                    holographicSweepOverlay
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .onAppear {
            orbitRotation = 360
            corePulse = 1.15
            ambientGlow = 0.4
            holographicSweep = 1.0
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: 0x1A1A40),
                Color(hex: 0x1C2C5B),
                Color.black
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var ambientGlowOverlay: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color.white.opacity(ambientGlow), .clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
            )
            .blur(radius: 60)
            .scaleEffect(corePulse)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: corePulse)
    }
    
    private var orbitalParticles: some View {
        ZStack {
            OuterParticleRing(rotation: orbitRotation)
            InnerParticleRing(rotation: orbitRotation)
        }
    }
    
    private var coreAndText: some View {
        VStack(spacing: 12) {
            GlassCore()
                .frame(width: 100, height: 100)
            Text(headingOne)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.3), radius: 8)
            Text(headingTwo)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 140)
    }
    
    private var holographicSweepOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, Color.white.opacity(0.15), .clear]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .offset(x: holographicSweep * UIScreen.main.bounds.width)
        .blendMode(.overlay)
        .animation(.linear(duration: 5.0).repeatForever(autoreverses: false), value: holographicSweep)
        .ignoresSafeArea()
    }
}

// MARK: - Particle Ring Views
private struct OuterParticleRing: View {
    let rotation: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                ParticleView(
                    color: Color.blue.opacity(0.3),
                    size: 6,
                    radius: 90,
                    angle: Double(i) * .pi / 6 + rotation
                )
                .blur(radius: 0.5)
            }
        }
        .animation(.linear(duration: 12.0).repeatForever(autoreverses: false), value: rotation)
    }
}

private struct InnerParticleRing: View {
    let rotation: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                ParticleView(
                    color: Color.purple.opacity(0.25),
                    size: 5,
                    radius: 60,
                    angle: Double(i) * .pi / 4 - rotation * 1.5
                )
            }
        }
        .animation(.linear(duration: 12.0).repeatForever(autoreverses: false), value: rotation)
    }
}

private struct ParticleView: View {
    let color: Color
    let size: CGFloat
    let radius: Double
    let angle: Double
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .offset(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
    }
}

struct GlassCore: View {
    @State private var angle: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.blue.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 4)
                .background(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.6),
                                    Color.purple.opacity(0.3)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .blur(radius: 1)
                )
                .shadow(color: .white.opacity(0.08), radius: 20)
            
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.5),
                            .blue.opacity(0.3),
                            .purple.opacity(0.4),
                            .white.opacity(0.2)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(angle))
                .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: angle)
        }
        .onAppear {
            angle = 360
        }
    }
}

struct SelectPhotoButton: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    @Binding var platformImage: PlatformImage?

    var body: some View {
        
        VStack(alignment: .center){
            
            Text("No Image Selected")
                .font(Font.custom("Poppins-Medium", size: 18))
                .foregroundColor(.white)
            
            PhotosPicker("Select Photo", selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            if let selectedImage{
                                platformImage = PlatformImage(image: selectedImage)
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}


extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}
