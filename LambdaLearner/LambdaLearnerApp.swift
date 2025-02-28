//
//  LambdaLearnerApp.swift
//  LambdaLearner
//
//  Created by Aditya Medhane on 28/02/25.
//

// MyApp.swift

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
//            SplashScreen()
            MainView()
        }
    }
}

// Section model to organize chapters
struct ChapterSection: Identifiable {
    let id: String
    let title: String
    let color: Color
    let chapters: [Chapter]
}

struct MainView: View {
    @State private var selectedChapter: Chapter?
    @State private var selectedTab = 0
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    let interpreter = Interpreter(options: InterpreterOptions(
        verbosity: .high,
        renameFreeVars: false,
        showEquivalent: true
    ))
    let text = State(initialValue: "")
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ChapterListView(selectedChapter: $selectedChapter, selectedTab: $selectedTab)
                .navigationTitle("Lambda Calculus")
        } detail: {
            if let chapter = selectedChapter {
                TabView(selection: $selectedTab) {
                    ChapterContentView(chapter: chapter)
                        .tabItem {
                            Image(systemName: "book.fill")
                            Text("Learn")
                        }
                        .tag(0)
                    
                    ContentView(interpreter: interpreter,
                                inputText: text.projectedValue)
                        .tabItem {
                            Image(systemName: "terminal.fill")
                            Text("Playground")
                        }
                        .tag(1)
                }
            } else {
                Text("Select a chapter to begin")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChapterListView: View {
    @Binding var selectedChapter: Chapter?
    @Binding var selectedTab: Int
    @State private var hoveredChapterId: Int? = nil
    
    // Organized sections with their respective chapters
    private let sections = [
        ChapterSection(
            id: "foundations",
            title: "Foundations",
            color: .blue,
            chapters: [
                Chapter(id: 1,
                        title: "Introduction to Lambda Calculus",
                        description: "Learn the foundations of functional programming through lambda calculus.")
                
            ]
        ),
        ChapterSection(
            id: "core",
            title: "Core Concepts",
            color: .purple,
            chapters: [
                Chapter(id: 2,
                        title: "The Inner Workings of Lambda Calculus",
                        description: "Discover how variables, equivalence, and substitution create the elegant machinery of lambda calculus."),
                Chapter(id: 3,
                        title: "Beta Reduction",
                        description: "Discover how lambda expressions are evaluated and the different strategies we can use."),
                Chapter(id: 4,
                        title: "Encoding Power of Lambda Calculus",
                        description: "Discover how lambda calculus can encode complex structures and computations using nothing but functions.")
            ]
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(sections) { section in
                    SectionView(
                        section: section,
                        selectedChapter: $selectedChapter,
                        selectedTab: $selectedTab,
                        hoveredChapterId: $hoveredChapterId
                    )
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
    }
}

struct SectionView: View {
    let section: ChapterSection
    @Binding var selectedChapter: Chapter?
    @Binding var selectedTab: Int
    @Binding var hoveredChapterId: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [section.color, section.color.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal)
            
            // Section title
            Text(section.title)
                .font(.headline)
                .foregroundColor(section.color)
                .padding(.horizontal)
            
            // Chapters in this section
            VStack(spacing: 8) {
                ForEach(section.chapters) { chapter in
                    ChapterItemView(
                        chapter: chapter,
                        isSelected: selectedChapter?.id == chapter.id,
                        isHovered: hoveredChapterId == chapter.id,
                        sectionColor: section.color
                    )
                    .onTapGesture {
                        selectedChapter = chapter
                        selectedTab = 0
                    }
                    .onHover { isHovered in
                        hoveredChapterId = isHovered ? chapter.id : nil
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ChapterItemView: View {
    let chapter: Chapter
    let isSelected: Bool
    let isHovered: Bool
    let sectionColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Lambda expression style header
                HStack(spacing: 4) {
                    Text("λ")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(sectionColor)
                    
                    Text("x.")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(sectionColor.opacity(0.7))
                    
                    Text("\(chapter.id)")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(sectionColor.opacity(0.5))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(sectionColor.opacity(0.1))
                )
                
                // Content with lambda theme
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(chapter.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Background with lambda watermark
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                    
                    // Subtle lambda watermark
                    Text("λ")
                        .font(.system(size: 60, weight: .thin, design: .monospaced))
                        .foregroundColor(sectionColor.opacity(0.03))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 50, y: 0)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                sectionColor.opacity(isSelected ? 0.8 : 0.2),
                                sectionColor.opacity(isSelected ? 0.4 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? sectionColor.opacity(0.3) : Color.gray.opacity(0.1),
                radius: isSelected ? 8 : 4
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
        .padding(.horizontal)
    }
}

struct SectionDivider: View {
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text("λ")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
}

// Model for Chapter data
struct Chapter: Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.id == rhs.id
    }
}

// Chapter Content View - This will render the appropriate chapter content
struct ChapterContentView: View {
    let chapter: Chapter
    
    var body: some View {
        switch chapter.id {
        case 1:
            Chapter1View()
        case 2:
            ChapterTwoView()
        case 3:
            ChapterThreeView()
        case 4:
            ChapterFourView()
        default:
            Text("Chapter content coming soon!")
        }
    }
}
      
