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
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    init(numOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = Array<Card>()
        // add numOfPairsOfCards x`2 cards to cards array
        for pairIndex in 0..<numOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: 2 * pairIndex))
            cards.append(Card(content: content, id: 2 * pairIndex + 1))
        }
        cards.shuffle()
    }
    
    struct Card: Identifiable {
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonustime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonustime()
            }
        }
        let content: CardContent
        let id: Int
        
        
        // MARK: - Bonus time
        
        // This could give matching bonus points
        // if the user matches the card
        // before a certain amount of time passes during which the card is face up
        
        // can be zero, means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        
        // the accumalated time this card has been face up in the past
        // (i.e not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0
        
        // how long this card has ever been face up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? (bonusTimeRemaining / bonusTimeLimit) : 0
        }
        
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && (bonusTimeRemaining > 0)
        }
        
        // whether we are currently face up, not matched and have not run out of bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && (bonusTimeRemaining > 0)
        }
        
        // called when card transition to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        // called when card goes back face down (or gets matched)
        private mutating func stopUsingBonustime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpDate = nil
        }
        
    }
    
}

extension Array {
    var oneAndOnly: Element? {
        (self.count == 1) ? self.first : nil
    }
}
