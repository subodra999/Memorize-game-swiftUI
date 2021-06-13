//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Subodra Banik on 10/06/21.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(viewModel: EmojiMemoryGame())
        }
    }
}
