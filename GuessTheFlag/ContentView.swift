//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Tomek on 21/01/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var showingScore = false
    @State private var showingFinalAlert = false
    @State private var scoreTitle = ""
    @State private var scoreMessage = ""
    @State private var score = 0
    @State private var numberOfAnswers = 0
    @State private var currentAnswer = 1
    var maxAnswers = 8
    
    @State private var rotateAmount = [0.0,0.0,0.0]
    @State private var opacityAmount = [1.0,1.0,1.0]
    @State private var scaleAmount = [1.0,1.0,1.0]
    @State private var offsetXAmount = [0.0,0.0,0.0]
    @State private var offsetYAmount = [0.0,0.0,0.0]
    
    @State private var countries = ["Estonia","France","Germany","Ireland","Italy","Monaco","Nigeria","Poland","Russia","Spain","UK","US"]
        .shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    var body: some View {
        ZStack {
            RadialGradient(
                stops: [
                    .init(color: .blue, location: 0.31),
                    .init(color: .red, location: 0.32)
                    ],
                center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("\(currentAnswer) / \(maxAnswers)")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack {
                        Text("Tap the flag of")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.secondary)
                        
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(countryName: countries[number])
                                .rotation3DEffect(.degrees(rotateAmount[number]), axis: (x: 0, y: 1, z: 0))
                                .opacity(opacityAmount[number])
                                .scaleEffect(scaleAmount[number])
                                .offset(x: offsetXAmount[number], y: offsetYAmount[number])
                                .transition(.slide)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Spacer()
                Spacer()
            }
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("\(scoreMessage)")
        }
        .alert(scoreTitle, isPresented: $showingFinalAlert) {
            if(numberOfAnswers == maxAnswers) {
                Button("Reset", action: resetGame)
            } else {
                Button("Continue", action: askQuestion)
            }
        } message: {
            Text("\(scoreMessage)")
        }
    }
    
    func flagTapped(_ number: Int) {
        numberOfAnswers += 1
        if (number == correctAnswer) {
            score += 1
            scoreTitle = "Correct!"
            scoreMessage = ""
        } else {
            scoreTitle = "Wrong!"
            scoreMessage = "That's the flag of \(countries[number])"
        }
        withAnimation {
            rotateAmount[number] = 360
            for nr in 0 ..< opacityAmount.count {
                if nr != number {
                    opacityAmount[nr] = 0.25
                    scaleAmount[nr] = 0.75
                    
                    if number == 1 {
                        offsetXAmount[nr] = 0
                        offsetYAmount[nr] = 50 * Double(nr == 0 ? -1 : 1)
                    } else {
                        offsetXAmount[nr] = 200 * Double(nr % 2 == 0 ? -1 : 1) * Double(number == 0 ? -1 : 1)
                        offsetYAmount[nr] = 0
                    }
                } else {
                    scaleAmount[nr] = 1.25
                }
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingScore = true
        }
    }
    
    func askQuestion() {
        if(numberOfAnswers == maxAnswers){
            scoreTitle = "End of the game"
            scoreMessage = "Your score is \(score)"
            showingFinalAlert = true
        } else {
            currentAnswer += 1
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
        }
        
        withAnimation {
            rotateAmount = [0.0,0.0,0.0]
            opacityAmount = [1.0,1.0,1.0]
            scaleAmount = [1.0,1.0,1.0]
            offsetXAmount = [0.0,0.0,0.0]
            offsetYAmount = [0.0,0.0,0.0]
        }
    }
    
    func resetGame() {
        currentAnswer = 0
        score = 0
        numberOfAnswers = 0
        askQuestion()
    }
}

struct FlagImage: View {
    
    var countryName: String
    
    var body: some View {
        Image(countryName)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
