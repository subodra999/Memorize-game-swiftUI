//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Subodra Banik on 12/06/21.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    //MARK: Type Variables
    private static let emojis = ["🐶", "🐸", "🐷", "🐔", "🐵", "🐮", "🐱", "🐯", "🐨", "🐥", "🐼", "🐰", "🐹"]
    
    private static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>.init(numOfPairsOfCards: 8) { pairIndex -> String in
            emojis[pairIndex % emojis.count] // to be index safe
        }
    }
    
    //MARK: Instance Variables
    @Published private var model = createMemoryGame()
    
    var cards: Array<Card> {
        return model.cards
    }
    
    //MARK: Intent(s)
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func restart() {
        model = EmojiMemoryGame.createMemoryGame()
    }
}
