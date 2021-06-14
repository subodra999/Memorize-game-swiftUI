//
//  ContentView.swift
//  Memorize
//
//  Created by Subodra Banik on 10/06/21.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    
    @ObservedObject var game: EmojiMemoryGame
    
    @State private var dealt = Set<Int>()
    
    @Namespace private var dealingNameSpace // for dealing in effect
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        return -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay: Double = 0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (DrawingConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: DrawingConstants.dealDuration).delay(delay)
    }
    
    var body: some View {
        VStack {
            title
            gameBody
            deckBody
            shuffleButton
        }
        .padding()
    }
    
    var title: some View {
        Text("Memorize!")
            .font(.largeTitle)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .padding(4)
                    .zIndex(zIndex(of: card))
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(.red)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: DrawingConstants.undealtWidth, height: DrawingConstants.undealtHeight)
        .foregroundColor(.red)
        .onTapGesture {
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var shuffleButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .fill()
                .foregroundColor(.red)
                .opacity(DrawingConstants.buttonOpacity)
                .aspectRatio(9, contentMode: .fit)
            Button("Shuffle") {
                withAnimation {
                    game.shuffle()
                }
            }
        }
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 20
        static let buttonOpacity: Double = 0.9
        static let aspectRatio: CGFloat = 2/3
        static let undealtHeight: CGFloat = 90
        static let undealtWidth: CGFloat = undealtHeight * aspectRatio
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
    }
    
}

struct CardView: View {
    
    let card: EmojiMemoryGame.Card
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 260-90))
                    .padding(5)
                    .opacity(DrawingConstants.circleOpacity)
                Text(card.content)
                    .rotationEffect(Angle(degrees: card.isMatched ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontSize: CGFloat = 32
        static let fontScale: CGFloat = 0.75
        static let circleOpacity: Double = 0.5
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(game.cards.first!)
        return EmojiMemoryGameView(game: game)
    }
}
