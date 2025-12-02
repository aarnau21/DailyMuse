//
//  PartsView.swift
//  DailyMuse
//
//  Created by Aarna Upadhyaya on 11/12/25.
//
import SwiftUI

//reusable subview for the card decks
struct CardView: View {
    let card: MuseCard
    
    // cream color
    let paperColor = Color(red: 0.98, green: 0.97, blue: 0.95)
    
    // goldish color for card border
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
                // checks which optional has a value
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
    
    // subview for the art
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
    
    // subview for the poem
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
                
                // the poem lines
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

//card struct
struct MuseDetailView: View {
    let card: MuseCard
    
    let appBackgroundColor = Color(red: 0.46, green: 0.25, blue: 0.20)
    let paperColor = Color(red: 0.98, green: 0.97, blue: 0.95)
    
    var body: some View {
        ZStack {
            appBackgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    //actual card
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(paperColor)
                            .shadow(radius: 5)
                        
                        VStack {
                            if let art = card.art {
                                // displays the art
                                if let url = art.imageURL {
                                    AsyncImage(url: url) { image in
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .cornerRadius(8)
                                }
                                Text(art.title)
                                    .font(.system(.title2, design: .serif))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding(.top)
                                Text(art.artist_display ?? "Unknown")
                                    .font(.system(.subheadline, design: .serif))
                                    .italic()
                            } else if let poem = card.poem {
                                // displays the poem
                                Text(poem.title)
                                    .font(.system(.title2, design: .serif))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                Text("by \(poem.author)")
                                    .italic()
                                    .padding(.bottom)
                                
                                Divider()
                                
                                ForEach(poem.lines, id: \.self) { line in
                                    Text(line)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding()
                    
                    // description for the the artwork
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About this piece")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .textCase(.uppercase)
                        
                        Text(generateDescription())
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // description for the ones that don't have it available
    func generateDescription() -> String {
        if let art = card.art {
            return "This visual work, titled \"\(art.title)\", is a testament to the artistic vision of \(art.artist_display ?? "the artist"). Preserved by the Art Institute of Chicago, it invites the viewer to explore themes of composition, color, and history."
        } else if let poem = card.poem {
            return "Written by \(poem.author), \"\(poem.title)\" is a literary composition comprising \(poem.lines.count) lines. It weaves language together to evoke emotion, rhythm, and imagery, preserving the poet's voice for future generations."
        }
        return "A beautiful piece saved to your collection."
    }
}
