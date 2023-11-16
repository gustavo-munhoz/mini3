import SwiftUI

struct YoutubeView: View {

    let video: VideoPosition
    var onSelected: () -> Void
    var isSelected: Bool
    var fontSize: CGFloat

    
    var body: some View {
        
        VStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                image.resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
//            .frame(maxWidth: 480, maxHeight: 360)
            .cornerRadius(fontSize * 0.05)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(.black, lineWidth: 1)
            )
            Spacer()
            VStack{
                Text(video.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .truncationMode(.tail)
                    .frame(maxWidth: 480)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Link("Watch on YouTube", destination: video.videoURL)
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    .padding(.bottom)
            }

        }
        .padding(.vertical, 40)
        .background(Color.appBlack)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.5)
            .stroke(Color.appBlue, lineWidth: 1)
        )
    }
}

#Preview {
    YoutubeView(video: VideoPosition(title: "Tate McRae, Khalid - working (Official Video)", thumbnailURL: "https://i.ytimg.com/vi/9pfPGVfMH74/hqdefault.jpg", videoURL: (URL(string: "https://www.youtube.com/watch?=9pfPGVfMH74") ?? URL(string: "https://www.youtube.com")!)), onSelected: {
        print("Oskay")
    }, isSelected: false, fontSize: 16)
}
