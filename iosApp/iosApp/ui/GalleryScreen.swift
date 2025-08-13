import SwiftUI
import Photos
import shared

struct GalleryScreen: View {
    @Binding var navPath: NavigationPath
    let processor: PROCESSOR
    @State private var images: [UIImage] = []
    @State private var loadedAssetIDs: Set<String> = []
    @State private var permissionStatus: PHAuthorizationStatus = .notDetermined
    @State private var showPermissionAlert = false
    @State private var isLoading = false
    @State private var currentPage = 0
    @State private var canLoadMore = true
    private let imagesPerPage = 20 // Number of images per page
    
    @EnvironmentObject var viewModelStoreOwner: IOSViewModelStoreOwner
    @EnvironmentObject var appContainer: ObservableValueWrapper<AppContainer>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
            ZStack {
                Image("ic_splash_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(alignment: .center) {
                    if permissionStatus == .authorized {
                        if isLoading && images.isEmpty {
                            // Enhanced loading view
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                Text("Loading Your Photos...")
                                    .font(Font.custom("Poppins-Medium", size: 20))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else if images.isEmpty {
                            // Enhanced "No Images Found" view
                            VStack(spacing: 16) {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("No Images Found")
                                    .font(Font.custom("Poppins-Bold", size: 24))
                                    .foregroundColor(.white)
                                Text("Your photo library appears to be empty.")
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                    ForEach(images.indices, id: \.self) {index in
                                        
                                        ImageView(image: images[index])
                                            .onTapGesture {
//                                                navPath.append(Destination.processing(processor: processor, selectedImage: images[index]))
                                            }.id(index)
                                       
                                    }
                                    
                                    // Progress bar for loading more images
                                    if canLoadMore {
                                        VStack {
                                            if isLoading {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        
                                            } else {
                                                Color.clear
                                                    .frame(height: 50)
                                                    .onAppear {
                                                        loadMoreImages()
                                                    }
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    } else {
                        
                        ZStack{
                            VStack(spacing: 16) {
                                Text("Photo library access is required to access your photos.")
                                    .font(Font.custom("Poppins-Regular", size: 18))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Button("Request Permission") {
                                    requestPhotoLibraryPermission()
                                }
                                .buttonStyle(.bordered)
                                .tint(.white)
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 40)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            
                        }
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
              
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.top, 60)
                .alert(isPresented: $showPermissionAlert) {
                    Alert(
                        title: Text("Permission Denied"),
                        message: Text("Please enable photo library access in Settings to view your images."),
                        primaryButton: .default(Text("Settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .onAppear {
                    checkPermissionStatus()
                    if images.isEmpty {
                        currentPage = 0
                        canLoadMore = true
                        isLoading = true
                        fetchImages(page: 0)
                    }
                }
            }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Gallery")
                        .font(Font.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func checkPermissionStatus() {
        permissionStatus = PHPhotoLibrary.authorizationStatus()
        print("Permission Status: \(permissionStatus.rawValue)")
        if permissionStatus == .authorized {
            isLoading = true
            fetchImages(page: currentPage)
        } else {
            print("Photo library access not authorized")
        }
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                permissionStatus = status
                if status == .authorized {
                    isLoading = true
                    fetchImages(page: currentPage)
                } else if status == .denied || status == .restricted {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    private func fetchImages(page: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            print("Fetching images for page \(page)")

            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            print("Total assets available: \(fetchResult.count)")

            // Calculate the range for the current page
            let startIndex = page * imagesPerPage
            let endIndex = min(startIndex + imagesPerPage, fetchResult.count)
            guard startIndex < fetchResult.count else {
                DispatchQueue.main.async {
                    print("No more images to fetch")
                    canLoadMore = false
                    isLoading = false
                }
                return
            }

            let range = startIndex..<endIndex
            let assets = fetchResult.objects(at: IndexSet(range))
                .filter { !loadedAssetIDs.contains($0.localIdentifier) } // skip already loaded

            print("Fetching \(assets.count) NEW assets for page \(page)")

            // Use PHCachingImageManager
            let imageManager = PHCachingImageManager()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isNetworkAccessAllowed = true // Allow iCloud images

            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: 300 * scale, height: 300 * scale)
            print("Target size: \(targetSize)")

            // Pre-cache assets
            imageManager.startCachingImages(
                for: assets,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: requestOptions
            )

            var fetchedImages: [UIImage] = []
            var newAssetIDs: [String] = []
            let dispatchGroup = DispatchGroup()

            for (index, asset) in assets.enumerated() {
                dispatchGroup.enter()
                imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFit,
                    options: requestOptions
                ) { image, info in
                    if let image = image {
                        fetchedImages.append(image)
                        newAssetIDs.append(asset.localIdentifier)
                        print("Fetched image \(index + 1) for page \(page)")
                    } else {
                        print("Failed to fetch image \(index + 1): \(String(describing: info))")
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                images.append(contentsOf: fetchedImages)
                loadedAssetIDs.formUnion(newAssetIDs) // mark as loaded
                print("Total images fetched for page \(page): \(fetchedImages.count)")
                print("Total images in state: \(images.count)")
                canLoadMore = endIndex < fetchResult.count
                isLoading = false

                imageManager.stopCachingImages(
                    for: assets,
                    targetSize: targetSize,
                    contentMode: .aspectFit,
                    options: requestOptions
                )
            }
        }
    }

    
    private func loadMoreImages() {
        guard canLoadMore && !isLoading else { return }
        isLoading = true
        currentPage += 1
        print("Loading more images for page \(currentPage)")
        fetchImages(page: currentPage)
    }
}
struct ImageView: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
