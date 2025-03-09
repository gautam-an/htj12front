import SwiftUI
import AVKit

struct CalendarProgressView: View {
    @State private var selectedDate: Date = Date()
    @State private var isExpanded: Bool = false
    @State private var videoURL: URL?
    @State private var shouldNavigateToVideo: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.cyan]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    DatePicker("Select a Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .onChange(of: selectedDate) { _ in
                            withAnimation {
                                isExpanded = true
                            }
                            loadVideoForDate()
                        }
                    
                    if videoURL != nil {
                        NavigationLink(
                            destination: VideoPlayerView(videoURL: videoURL!),
                            isActive: $shouldNavigateToVideo
                        ) {
                            Button(action: {
                                shouldNavigateToVideo = true
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("View Video")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                    
                    if isExpanded {
                        ExpandedDateView(date: selectedDate)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    func loadVideoForDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let videoName = "\(dateFormatter.string(from: selectedDate)).mov"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoPath = documentsDirectory.appendingPathComponent(videoName)
        
        print("Looking for video at: \(videoPath.path)")
        
        if FileManager.default.fileExists(atPath: videoPath.path) {
            videoURL = videoPath
            print("Loading video for date: \(selectedDate)")
        } else {
            videoURL = nil
            print("No video found for date: \(selectedDate)")
        }
    }
}

struct VideoPlayerView: View {
    var videoURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarTitle("Video Playback", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        )
    }
}

struct ExpandedDateView: View {
    var date: Date
    
    var body: some View {
        VStack {
            Text("Selected Date: \(date.formatted(date: .long, time: .omitted))")
                .font(.title2)
                .padding()
                .background(Color.cyan.opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 20)
            
            Text("Details for the selected date go here.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    CalendarProgressView()
}
