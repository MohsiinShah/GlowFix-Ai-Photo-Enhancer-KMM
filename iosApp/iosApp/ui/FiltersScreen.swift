//
//  FiltersScreen.swift
//  iosApp
//
//  Created by Mohsin on 11/08/2025.
//  Copyright © 2025 orgName. All rights reserved.
//

import SwiftUICore
import SwiftUI
import shared
import Photos

struct FiltersScreen: View{
    
    @Binding var navPath: NavigationPath
    
    let path: String
    
    let selectedProcessor: PROCESSOR
    
    @EnvironmentObject var viewModelStoreOwner: IOSViewModelStoreOwner
    
    @EnvironmentObject var appContainer: ObservableValueWrapper<AppContainer>
    
    
    let mColorDullWhite = Color("DividerColor")
    
    let mBlackTwentyPercent = Color("BlackTen")
    
    @State private var filters: [Filter] = []
    
    @State private var filteredImage: UIImage? = nil
    
    let processor = ImageFilterProcessor()
    
    @State private var editedImagePath = ""
    
    @State private var showConfirmationDialog = false
        
    let filterData: [(filterType: FilterType, label: String)] = [
        (.reset, "Reset"),
        (.vintage, "Vintage"),
        (.lomo, "Lomo"),
        (.clarendon, "Clarendon"),
        (.valencia, "Valencia"),
        (.amaro, "Amaro"),
        (.gingham, "Gingham"),
        (.juno, "Juno"),
        (.moon, "Moon"),
        (.nashville, "Nashville"),
        (.xproii, "X-Pro II"),
        (.lofi, "Lo-Fi"),
        (.toaster, "Toaster"),
        (.hudson, "Hudson"),
        (.perpetua, "Perpetua"),
        (.mayfair, "Mayfair")
    ]
    
    var body: some View {
        
        let photoEnhancerVm: PhotoEnhancerViewModel = viewModelStoreOwner.viewModel(
            factory: appContainer.value.photoEnhancerVMFactory
        )
        

            ZStack {
                           
                           Image("ic_splash_bg")
                               .resizable()
                               .scaledToFill()
                               .ignoresSafeArea()
                           
                           VStack(spacing: 0) {
                               
                               // Image preview area - takes all available space
                               ZStack {
                                   mBlackTwentyPercent // background color of the box
                                   
                                   if let image = filteredImage {
                                       Image(uiImage: image)
                                           .resizable()
                                           .scaledToFit()
                                           .clipped()
                                           .padding()
                                   } else {
                                       Image(uiImage: UIImage(contentsOfFile: path)!)
                                           .resizable()
                                           .scaledToFit()
                                           .clipped()
                                           .padding()
                                   }
                               }
                               .frame(maxWidth: .infinity, maxHeight: .infinity) // Take all available space
                               .clipShape(RoundedRectangle(cornerRadius: 24))
                               .padding(.horizontal, 20)
                               .padding(.top, 80) // Add top padding to avoid toolbar overlap
                               
                               // Filters scroll view - fixed height at bottom
                               ScrollView(.horizontal, showsIndicators: false) {
                                   LazyHStack(spacing: 16) {
                                       ForEach(filterData, id: \.filterType) { item in
                                           FilterItem(
                                               filterType: item.filterType,
                                               label: item.label
                                           ) { type in
                                               filters = [Filter(type: type, intensity: 1.0)]
                                           }
                                       }
                                   }
                                   .padding(.horizontal, 10)
                               }
                               .frame(height: 180, alignment: Alignment.bottom) // Fixed height for the filter section
                               .padding(.top, 16)
                               .padding(.bottom, 40)
                           }
                          // This respects the safe area at the bottom
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Ai Enhance")
                            .font(Font.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showConfirmationDialog = true
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                        .onTapGesture {
                            navPath.append(Destination.result(path: filters.isEmpty ? path : (editedImagePath.isEmpty ? path : editedImagePath), processor: selectedProcessor))
                        }
                }
                
            }
            .onChange(of: filters) { oldValue, newValue in
                Task {
                    if let baseImage = UIImage(contentsOfFile: path) {
                        let newFiltered = await processor.applyFilters(
                            to: baseImage,
                            filters: newValue
                        ) ?? baseImage
                        
                        filteredImage = newFiltered
                        if let savedPath = saveImageToTemp(newFiltered) {
                            editedImagePath = savedPath
                        }
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to go back? Changes will be lost.",
                isPresented: $showConfirmationDialog,
                titleVisibility: .visible,
                actions: {
                    Button("Yes", role: .destructive) {
                        photoEnhancerVm.clearState()
                        navPath.removeLast(2)
                    }
                    Button("No", role: .cancel) {
                        
                    }
                },
                message: {
                    Text("Any edits you’ve made will be discarded.")
                }
            )
            .onDisappear{
                photoEnhancerVm.clearState()
            }
            .navigationBarBackButtonHidden(true)
        
    }
    
    private func saveImageToTemp(_ image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil } // Lossless PNG
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".png")
        do {
            try data.write(to: tempURL)
            return tempURL.path
        } catch {
            print("Error saving image:", error)
            return nil
        }
    }
    
    
}

struct FilterItem: View {
    
    let filterType: FilterType
    let label: String
    let onFilterSelected: (FilterType) -> Void
    let processor = ImageFilterProcessor()
    @State private var filteredImage: UIImage? = nil
    
    
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                if let image = filteredImage{
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: 100, maxHeight: 130)
                        .scaledToFit()
                } else {
                    Image("ic_person_filters")
                        .resizable()
                        .frame(maxWidth: 100, maxHeight: 130)
                        .scaledToFit()
                }
                
                
                Text(label)
                    .font(Font.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.white)
            }
        }
        .onTapGesture {
            onFilterSelected(filterType)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            if let baseImage = UIImage(named: "ic_person_filters") {
                filteredImage = await processor.applyFilters(
                    to: baseImage,
                    filters: [Filter(type: filterType, intensity: 1.0)]
                ) ?? baseImage
            }
        }
        
    }
}
