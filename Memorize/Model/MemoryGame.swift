//
//  MemoryGame.swift
//  Memorize
//
//  Created by Subodra Banik on 12/06/21.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    
    private(set) var cards: Array<Card>
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly
        } set {
            cards.indices.forEach { cards[$0].isFaceUp = ($0 == newValue) }
        }
    }
    
    mutating func choose(_ card: Card) {
        if let choosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[choosenIndex].isMatched,
           !cards[choosenIndex].isFaceUp
           {
            
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[choosenIndex].content == cards[potentialMatchIndex].content {
                    // it's a match
                    cards[choosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[choosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = choosenIndex
            }
            
        }
    }
    
    init(numOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = Array<Card>()
        // add numOfPairsOfCards x`2 cards to cards array
        for pairIndex in 0..<numOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: 2 * pairIndex))
            cards.append(Card(content: content, id: 2 * pairIndex + 1))
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp = false
        var isMatched = false
        let content: CardContent
        let id: Int
    }
}

extension Array {
    var oneAndOnly: Element? {
        (self.count == 1) ? self.first : nil
    }
}
