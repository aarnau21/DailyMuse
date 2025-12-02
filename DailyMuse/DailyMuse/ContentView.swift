//
//  ContentView.swift
//  DailyMuse
//
//  Created by Aarna Upadhyaya on 11/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMoodIndex: Int = 0 // mood
    @State private var userName: String = "" //text type
    @State private var deck: [MuseCard] = [] //the stack of cards
    @State private var gallery: [MuseCard] = [] //saved cards
    @State private var isLoading = false // loading spinner
    @State private var showGallery = false //makes gallery show up
    //name input visibility
    @State private var isEditingName: Bool = false
    //first screen
    @State private var showSplashScreen: Bool = true
    //name screen
    @State private var showNameEntry: Bool = false
    
    //tracks the finger when they're swiping
    @State private var offset = CGSize.zero
    
    //brown background color
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
                                
                                // brings back the name editor
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
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        
                        //only shows if you're editnig name
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
                        //drop down for the emotions
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
                            //loading screen
                            if isLoading {
                                ProgressView("Summoning the Muses...")
                                    .foregroundColor(.white)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else if deck.isEmpty {
                                VStack {
                                    //when nothing has been chosen
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
                                    //animation for the card sliding and then disappearing
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
                        
                        //instructoins for swipes
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
            .disabled(showSplashScreen || showNameEntry)
            
           
            if showNameEntry {
                NameEntryView(userName: $userName, isActive: $showNameEntry)
                    .transition(.opacity)
                    .zIndex(2)
            }
            
         
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen, nextState: $showNameEntry)
                    .transition(.opacity)
                    .zIndex(3)
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
            //appends the chosen art/poem to their gallery list
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
    @Binding var nextState: Bool
    
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
                nextState = true
            }
        }
    }
}

struct NameEntryView: View {
    @Binding var userName: String
    @Binding var isActive: Bool
    
    let appBackgroundColor = Color(red: 0.46, green: 0.25, blue: 0.20)
    let darkBoxColor = Color(red: 0.25, green: 0.15, blue: 0.12)
    
    var body: some View {
        ZStack {
            appBackgroundColor.ignoresSafeArea()
            
            VStack(spacing: 40) {
                VStack(spacing: 10) {
                    Text("DailyMuse")
                        .font(.system(size: 45, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("long live the arts.")
                        .font(.system(size: 20, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 50)
                
                Spacer()
                
                ZStack {
                    //box for the user to enter their name
                    Rectangle()
                        .fill(darkBoxColor)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 15) {
                        Text("Tell us what to call you:")
                            .font(.system(size: 18, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                        
                        TextField("", text: $userName)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .submitLabel(.done)
                            .onSubmit {
                                // go back to the main app
                                withAnimation {
                                    isActive = false
                                }
                            }
                        
                        //underline
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 200)
                    }
                }
                
                Spacer()
                
                //continue
                Button(action: {
                    withAnimation {
                        isActive = false
                    }
                }) {
                    Text("Continue →")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 50)
                .opacity(userName.isEmpty ? 0 : 1)
            }
        }
    }
}

struct GalleryView: View {
    @Binding var savedCards: [MuseCard]
    @Environment(\.dismiss) var dismiss
    
    //paper view color
    let paperColor = Color(red: 0.98, green: 0.97, blue: 0.95)
    
    var body: some View {
        NavigationView {
            List {
                ForEach(savedCards) { card in
                    //lets you see what you saved when you click
                    NavigationLink(destination: MuseDetailView(card: card)) {
                        HStack {
                            if let work = card.art {
                                Text("🎨 \(work.title)")
                                    .font(.system(.body, design: .serif))
                            } else if let poem = card.poem {
                                Text("📜 \(poem.title)")
                                    .font(.system(.body, design: .serif))
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    //paper color for gallery
                    .listRowBackground(paperColor)
                }
                .onDelete(perform: delete)
            }
            //changes default color to paper
            .scrollContentBackground(.hidden)
            .background(paperColor)
            .navigationTitle("My Gallery")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
        .accentColor(Color(red: 0.46, green: 0.25, blue: 0.20))
    }
    
    func delete(at offsets: IndexSet) {
        savedCards.remove(atOffsets: offsets)
    }
}
