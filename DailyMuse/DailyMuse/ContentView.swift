import SwiftUI

struct ContentView: View {
    @State private var selectedMoodIndex: Int = 0
    @State private var userName: String = ""
    @State private var deck: [MuseCard] = []
    @State private var gallery: [MuseCard] = []
    @State private var isLoading = false
    @State private var showGallery = false
    //name input visibility
    @State private var isEditingName: Bool = true
    @State private var showSplashScreen: Bool = true
    //checks if the width/height of the search box is zero
    @State private var offset = CGSize.zero
    
    let appBackgroundColor = Color(red: 0.46, green: 0.25, blue: 0.20)
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    appBackgroundColor
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("DailyMuse")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(userName.isEmpty ? "Hello, Muse" : "Hello, \(userName)")
                                    .foregroundColor(Color(UIColor.lightText))
                                    .onTapGesture {
                                        withAnimation {
                                            isEditingName = true
                                        }
                                    }
                            }
                            Spacer()
                            Button(action: { showGallery.toggle() }) {
                                Image(systemName: "books.vertical")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        
                        if isEditingName {
                            TextField("Enter your name for the journal...", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .onSubmit {
                                    withAnimation {
                                        isEditingName = false
                                    }
                                }
                        }
                        
                        HStack {
                            Text("I am feeling:")
                                .foregroundColor(.white)
                            
                            Picker("Mood", selection: $selectedMoodIndex) {
                                ForEach(0..<availableMoods.count, id: \.self) { index in
                                    Text(availableMoods[index].name).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(.white)
                            .onChange(of: selectedMoodIndex) { _ in
                                Task {
                                    await refreshDeck()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        
                        ZStack {
                            if isLoading {
                                ProgressView("Summoning the Muses...")
                                    .foregroundColor(.white)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else if deck.isEmpty {
                                VStack {
                                    Image(systemName: "sparkles")
                                        .font(.largeTitle)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Select a mood to inspire the deck.")
                                        .foregroundColor(.white.opacity(0.8))
                                    Button("Refresh Daily Inspiration") {
                                        Task { await refreshDeck() }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            } else {
                                ForEach(deck.reversed()) { card in
                                    CardView(card: card)
                                        .rotationEffect(.degrees(getRotation(for: card)))
                                        .offset(x: getOffset(for: card).width, y: 0)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    if card.id == deck.first?.id {
                                                        offset = gesture.translation
                                                    }
                                                }
                                                .onEnded { _ in
                                                    if abs(offset.width) > 100 {
                                                        if offset.width > 0 {
                                                            saveToGallery(card)
                                                        }
                                                        removeCard()
                                                    } else {
                                                        offset = .zero
                                                    }
                                                }
                                        )
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        
                        if !deck.isEmpty {
                            HStack {
                                Text("← Discard")
                                Spacer()
                                Text("Save →")
                            }
                            .padding()
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showGallery) {
                    GalleryView(savedCards: $gallery)
                }
            }
            
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
        
    func refreshDeck() async {
        isLoading = true
        deck = []
        
        let currentMood = availableMoods[selectedMoodIndex]
        
        do {
            async let fetchedArt = MuseService.fetchArt(searchTerm: currentMood.searchTerm)
            async let fetchedPoems = MuseService.fetchPoems(searchTerm: currentMood.searchTerm)
            
            let art = try await fetchedArt
            let poems = try await fetchedPoems
            
            var newDeck: [MuseCard] = []
            
            for item in art.prefix(2) {
                newDeck.append(MuseCard(art: item, poem: nil))
            }
            for item in poems.prefix(2) {
                newDeck.append(MuseCard(art: nil, poem: item))
            }
            
            deck = newDeck.shuffled()
            
        } catch {
            print("Error fetching inspiration: \(error)")
        }
        
        isLoading = false
    }
    
    func getOffset(for card: MuseCard) -> CGSize {
        if card.id == deck.first?.id {
            return offset
        }
        return .zero
    }
    
    func getRotation(for card: MuseCard) -> Double {
        if card.id == deck.first?.id {
            return Double(offset.width / 20)
        }
        return 0
    }
    
    func removeCard() {
        withAnimation {
            offset = .zero
            if !deck.isEmpty {
                deck.removeFirst()
            }
        }
    }
    
    func saveToGallery(_ card: MuseCard) {
        if !gallery.contains(where: { $0.id == card.id }) {
            gallery.append(card)
        }
    }
}

struct SplashScreenView: View {
    @Binding var isActive: Bool
    
    let appBackgroundColor = Color(red: 0.46, green: 0.25, blue: 0.20)
    
    var body: some View {
        ZStack {
            appBackgroundColor.ignoresSafeArea()
            
            VStack(spacing: 15) {
                Text("DailyMuse")
                    .font(.system(size: 55, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text("long live the arts.")
                    .font(.system(size: 22, design: .serif))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.8)) {
                isActive = false
            }
        }
    }
}

struct GalleryView: View {
    @Binding var savedCards: [MuseCard]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(savedCards) { card in
                    HStack {
                        if let work = card.art {
                            Text("🎨 \(work.title)")
                        } else if let poem = card.poem {
                            Text("📜 \(poem.title)")
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("My Gallery")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    func delete(at offsets: IndexSet) {
        savedCards.remove(atOffsets: offsets)
    }
}
