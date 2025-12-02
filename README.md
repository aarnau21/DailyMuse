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

# Images

<h4> Opening Spash-Screen </>
  
<img src="https://github.com/user-attachments/assets/1177078f-386c-46bd-a718-a0a84ff2a8a6" width="300" />

<h4>User is prompted to enter their name</h3>
<img src="https://github.com/user-attachments/assets/adfa05fe-c5c2-4797-bbda-f4ff26a9d269" width="300"/>

<h4>Homescreen; here, they can choose from a drop down what they're feeling</h3>
<img src="https://github.com/user-attachments/assets/bf7edcd4-fa56-4c17-a809-3d4e4e6e69ce" width="300"/>
<img src="https://github.com/user-attachments/assets/51cbda1f-88fd-4f73-8ef5-b29f90450a28" width="300"/>

<h4>Example of a poem:</h3>
<img src="https://github.com/user-attachments/assets/893741f6-d5ef-43e7-bf66-b247d39a3214" width="300"/>

<h4>Example of an art piece:</h3>
<img src="https://github.com/user-attachments/assets/965f57b6-0fa7-481a-b392-fbb61f3d3ac8" width="300"/>

<h4>User's gallery view; if they swiped right, these selections would appear here. They can swipe left on one of them if they wanted to delete:</h3>
<img src="https://github.com/user-attachments/assets/198eaee3-8485-4b87-8136-dd43a1e982aa" width="300"/>

<h4>If they click on one of their saved pieces, it allows them to see a short description about it:</h3>
<img src="https://github.com/user-attachments/assets/11b9df91-6d76-476b-85da-bda264b9b93c" width="300"/>
<img src="https://github.com/user-attachments/assets/f0d4d250-74ac-46e4-86ac-717873f8b1fc" width="300"/>




