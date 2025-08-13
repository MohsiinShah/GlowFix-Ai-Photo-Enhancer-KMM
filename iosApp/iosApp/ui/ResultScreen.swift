//
//  ResultScreen.swift
//  iosApp
//
//  Created by Mohsin on 07/08/2025.
//  Copyright © 2025 orgName. All rights reserved.
//
import SwiftUICore
import SwiftUI
import shared

struct ResultScreen: View {
    @Binding var navPath: NavigationPath
    
    let processor: PROCESSOR
    
    let path: String
        
    @EnvironmentObject var viewModelStoreOwner: IOSViewModelStoreOwner
    
    @EnvironmentObject var appContainer: ObservableValueWrapper<AppContainer>

    
    let mColorDullWhite = Color("DividerColor")
    
    let mBlackTwentyPercent = Color("BlackTen")
    
    @State private var downloaded = false
    
    var body: some View {
        
        let photoEnhancerVm: PhotoEnhancerViewModel = viewModelStoreOwner.viewModel(
            factory: appContainer.value.photoEnhancerVMFactory
        )
        
        let title = if processor == PROCESSOR.enhance {"Ai Enhance"} else {"Ai Remove"}
        
        let platformImage = PlatformImage(image: UIImage(contentsOfFile: path)!)
    
            Observing(photoEnhancerVm.processingState){ state in
            
                
                ZStack {
                    BackNavigationHandler {
                        if photoEnhancerVm.processingState.value is ProcessingState.Processing {
                            
                            return false
                        }
                        return true
                    }
                    .frame(width: 0, height: 0)
                    
                    
                    Image("ic_splash_bg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    
                    VStack{
                        
                        ZStack {
                            mBlackTwentyPercent // background color of the box
                            
                            Image(uiImage: UIImage(contentsOfFile: path)!)
                                .resizable()
                                .scaledToFit()
                                .clipped()
                                .padding()
                            
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        ZStack {
                            Image("ic_get_started")
                            HStack(alignment: .center){
                                Text("Download")
                                    .font(Font.custom("Poppins-Medium", size: 13))
                                    .foregroundColor(.white)
                            }
                            
                        }.padding(.bottom , 30)
                            .onTapGesture {
                                photoEnhancerVm.downloadImage(platformImage: platformImage)
                                
                            }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                }
                .onChange(of: state) { _, newState in
                    downloaded = newState is ProcessingState.Success
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
                        Button(action: {
                            if(processor == PROCESSOR.backgroundRemover){
                                navPath.removeLast(2)
                            }else{
                                navPath.removeLast()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                
                }
                
            }
            .onDisappear{
                photoEnhancerVm.clearState()
            }
            .alert("Download Successfully.", isPresented: $downloaded) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarBackButtonHidden(true)
        }
}
