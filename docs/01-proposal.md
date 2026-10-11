# Proposal

Paste in the proposal you submitted, and replace it with the final version when
the project is done. You do not need to keep it in sync week to week: nobody
reads this folder until you hand the project in.

Keep these headings so a reader can scan it:

## The problem, in one sentence
Cat owners often struggle to organize and access their cats' medical records, vaccination 
schedules, medications, and veterinary history because the information is scattered across paper records, clinic receipts, and personal notes, making long-term health management difficult. 

## Who it is for
PurrFile is designed primarily for cat owners, especially those who have multiple cats, cats
requiring regular medical care, or owners who want a more organized way to monitor their
cats' health.
Currently, cat owners may rely on paper vaccination cards, veterinary receipts,
handwritten notebooks, phone notes or calendar apps, spreadsheets, or simply their
memory to keep track of their cats' health information and appointments. These methods
can be difficult to organize and may result in misplaced records, missed vaccinations,
forgotten medications, or incomplete medical histories.
PurrFile brings this information together into one centralized application where cat owners
can manage their cats' profiles, health records, reminders, and general health questions.

## Core features
PurrFile is a mobile application designed to help cat owners organize and manage their cats’ health information in one place. Its three main features are Cat Profile Management, Health Record Management, and Reminders and Notifications. Users can create and manage cat profiles, store important information such as breed, age, and medical history, record veterinary visits and vaccinations, and set reminders for upcoming appointments, medications, and other health-related activities. The AI Health Assistant is also planned as an additional feature that can provide general cat health information, but it will only be developed after the main features are working.

## Out of scope, and why
The AI Health Assistant, downloadable health reports and charts, and cloud backup with multi-device synchronization are considered outside the minimum viable product (MVP). These features are optional because they require additional development time, API integration, and testing. The AI Health Assistant also needs to provide safe and reliable information without replacing professional veterinary advice. By focusing first on cat profiles, health records, and reminders, I can prioritize the most important functions and make the project more achievable within the semester.

## Data the app remembers, and where it is saved
PurrFile will use Supabase as its main database and persistent storage solution. User account information, including the user ID, name, and email, will be handled through Supabase Authentication. Cat profiles, including the cat's name, photo, breed, sex, date of birth, color, microchip number, and owner information, will be saved in the cats table. Health records, such as record type, date, description, veterinarian or clinic, notes, and next due date, will be stored in the health_records table. Reminders, including their type, date, and notification status, will be saved in the reminders table. If the AI Health Assistant is implemented, its conversations, questions, responses, and timestamps may be stored in the ai_conversations table. Each user should only be able to access their own cat information, health records, and reminders.

## Risks
One major risk is connecting the Flutter application to Supabase and ensuring that data can be saved and retrieved correctly. Since the app contains related information, errors in the database structure or connection could affect multiple screens. To reduce this risk, I plan to test the connection by creating a cat profile, saving it to Supabase, retrieving it, and displaying it in the application before implementing the complete storage system. Another risk is implementing the AI Health Assistant, especially ensuring that its responses are useful and safe. I will reduce this risk by treating AI as a stretch goal and building the main features first. I will also keep passwords, API keys, and other sensitive information outside the public GitHub repository.

## Changes since the last version
Since the previous version of my proposal, I have reduced the MVP from four main features to three by moving the AI Health Assistant to the stretch goals. This change will help me focus on completing cat profile management, health record management, and reminders within the available time. I have also selected Supabase as the planned persistent storage solution and identified the specific tables where the app's data will be saved. The screen structure has been clarified, with six main screens for the MVP and the AI chat screen treated as an optional extension. I also improved the design system by defining a consistent color palette, typography, spacing, and reusable UI components based on the updated mockups. These changes make the project more organized, realistic, and easier to develop and maintain.
