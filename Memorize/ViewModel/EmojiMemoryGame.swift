//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Subodra Banik on 12/06/21.
//

import SwiftUI

class EmojiMemoryGame {
    //MARK: Type Variables
    static let emojis = ["🐶", "🐸", "🐷", "🐔", "🐵", "🐮", "🐱", "🐯", "🐨", "🐥", "🐼", "🐰", "🐹"]
    
    static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>.init(numOfPairsOfCards: 4) { pairIndex -> String in
            emojis[pairIndex % emojis.count] // to be index safe
        }
    }
    
    //MARK: Instance Variables
    private var model: MemoryGame<String> = createMemoryGame()
    
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards
    }
    
}