# DailyMuse
A daily dose of curated art and poetry based on a user's chosen mood, presented in a "Tinder-style" swiping interface.

# Overview
DailyMuse is a daily wellness app that curates art and poetry based on the user's current emotional state. Users select their mood, and the app fetches relevant artworks from the Art Institute of Chicago and poetry from PoetryDB. Presented in a deck-of-cards interface, users can swipe right to save pieces to their personal gallery or left to discard them.

# Purpose
The purpose of DailyMuse is to connect users with art that actually resonates with them. I wanted to make interacting with poetry and art accessible in order to show the public that these pieces are meant to be relatable. 

# Features
Mood-Based Curation: The content displayed uses specific keyword mapping to match API results with the user's selected emotion (e.g., "Despair" searches for "Sorrow").

Interactive Deck Interface: Utilizes custom gesture recognizers to simulate a tactile "card stack" experience.

Hybrid Content Types: Blends visual art and text-based poetry into a unified data model (MuseCard) displayed in a consistent UI.

Personal Gallery: Users can curate their own collection of favorites which stays during the current session.


# Tools Used

-> Language: Swift 5.5+

-> Framework: SwiftUI

-> Networking: URLSession, Async/Await

-> APIs:
---> Art Institute of Chicago API (for Artwork)
---> PoetryDB (for Poems)

# Obstacles and Future Additions
Obstacle: finding an API that allowed searching poems by "mood" was difficult. I solved this by mapping moods to specific keywords (like "romance" for "love") to query the APIs effectively.

I plan to add CoreData or SwiftData persistence so the "My Gallery" list is saved even after the app closes. I also want to add a "Share" feature to post cards to social media, and an AI-Powered algorithim that allows a better selection process so users can see artwork/poems that matches pieces they've liked in the past.
