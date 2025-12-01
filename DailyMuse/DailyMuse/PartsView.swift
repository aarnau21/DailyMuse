//
//  PartsView.swift
//  DailyMuse
//
//  Created by Aarna Upadhyaya on 12/1/25.
//
import SwiftUI

struct CardView: View {
    let card: MuseCard
    //cream color
    let paperColor = Color(red: 0.98, green: 0.97, blue: 0.95)
    //gold-ish border
    let borderColor = Color(red: 0.85, green: 0.80, blue: 0.70)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(paperColor)
                .shadow(color: Color.black.opacity(0.15), radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(borderColor, lineWidth: 2)
                )
            
            VStack {
                // checking which opitonal has a value
                if let artwork = card.art {
                    artContent(artwork)
                } else if let poem = card.poem {
                    poemContent(poem)
                }
            }
            .padding(25)
        }
        .frame(width: 320, height: 540)
    }
    
    @ViewBuilder
    func artContent(_ artwork: ArtWork) -> some View {
        VStack(spacing: 15) {
            if let url = artwork.imageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(4)
                        .shadow(radius: 2)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 320)
            }
            
            VStack(spacing: 5) {
                Text(artwork.title)
                    .font(.system(.headline, design: .serif))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(artwork.artist_display ?? "Unknown Artist")
                    .font(.system(.caption, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func poemContent(_ poem: Poem) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                VStack(spacing: 4) {
                    Text(poem.title)
                        .font(.system(.title2, design: .serif))
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("by \(poem.author)")
                        .font(.system(.subheadline, design: .serif))
                        .italic()
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .background(borderColor)
                
                VStack(spacing: 6) {
                    ForEach(Array(poem.lines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 16, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                
                Text("❧")
                    .font(.title)
                    .foregroundColor(borderColor)
                    .padding(.top, 10)
            }
            .padding(.vertical)
        }
    }
}
