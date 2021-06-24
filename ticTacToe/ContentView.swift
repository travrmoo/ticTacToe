//
//  ContentView.swift
//  ticTacToe
//
//  Created by Travis Moody on 6/21/21.
//

import SwiftUI
//content view shows UI
struct ContentView: View {
    
    // array of three grid items to make up columns. contained in struct to limit scope access.
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    //State property. Array of moves. Move is optional(?). Repeats 9 nils in array.
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    //
    @State private var isGameboardDisabled = false
    @State private var alertItem: AlertItem?
    
    var body: some View {
        //geometry reader to create frame size
        GeometryReader { geometry in
            //VStack to put TTT board in middle of screen
            VStack{
                Spacer()
            //grid to display columns and change spacing
                LazyVGrid(columns: columns, spacing: 5) {
                //for each statement to create items in rows and columns
                // iterate 0-9 i = index to accomplish this
                ForEach(0..<9) { i in
                    //zstack to show X or O on circle.
                    ZStack {
                        //adds circle to grid
                        Circle()
                            //circle properties
                            .foregroundColor(.red).opacity(0.5)
                            //changes spacing. div by 3 to create equally spaced items. - 15 = padding.
                            .frame(width: geometry.size.width/3 - 15, height: geometry.size.width/3 - 15)
                        //add images on top of circles and change properties. If there is a move at index i, then use indicator. if nil then use blank.
                        Image(systemName: moves[i]?.indicator ?? "")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    //tap gesture to create move and add to Move array. i iterates 0-8. enum Player referenced here.
                    .onTapGesture {
                        //check to see if square is occupied
                        if isSquareOccupied(in: moves, forIndex: i) { return }
                        moves[i] = Move(player: .human, boardIndex: i)
                       
                        
                        if checkWinCondition(for: .human, in: moves){
                            alertItem = AlertContext.humanWin
                            return
                        }
                        
                        if checkForDraw(in: moves) {
                            alertItem = AlertContext.draw
                            return
                        }
                        
                        //board disabled for .5 seconds
                        isGameboardDisabled = true
                        //check for win or draw conditions.
                        
                        //delays computer move by half second
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            
                            let computerPosition = determineComputerMovePosition(in: moves)
                            //computer will determine its random move
                            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                            //enables board after computer moves
                            isGameboardDisabled = false
                            //check for computer win
                            if checkWinCondition(for: .computer, in: moves){
                                alertItem = AlertContext.computerWin
                                return
                            }
                            if checkForDraw(in: moves) {
                                alertItem = AlertContext.draw
                                return
                            }
                        }
                        
                    }
                }
            }//end of spacer that moves grid to middle of screen
            Spacer()
            }
            //moves grid in from screen edges
            .padding()
            .disabled(isGameboardDisabled)
            
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: .default(alertItem.buttonTitle, action: { resetGame() }))
            })
        }
    }
    //func to prevent taking a space thats already taken.
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: {$0?.boardIndex == index})
    }
    //code to have computer make its own move
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        
        //If AI can win, then win
        let winPatters: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        let computerMoves = moves.compactMap{ $0 }.filter {$0.player == .computer
        }
        let computerPositions = Set(computerMoves.map {$0.boardIndex})
        //go through each pattern (winPositions) and check to see if 2/3 are valid. subtract computer positions from this.
        for pattern in winPatters {
            let winPositions = pattern.subtracting(computerPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable {return winPositions.first!}
            }
        }
        //If AI can't win, then block
        let humanMoves = moves.compactMap{ $0 }.filter {$0.player == .human
        }
        let humanPositions = Set(humanMoves.map {$0.boardIndex})
        //go through each pattern (winPositions) and check to see if 2/3 are valid. subtract human positions from this.
        for pattern in winPatters {
            let winPositions = pattern.subtracting(humanPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable {return winPositions.first!}
            }
        }
        
        //If AI can't block, then take middle square
        let centerSquare = 4
        if !isSquareOccupied(in: moves, forIndex: 4) {
            return centerSquare
        }
        
        //If AI can't take middle square take random available square
        //random number generator to reference grid index
        var movePosition = Int.random(in: 0..<9)
        //checks if circle is taken. if yes tries new circle.
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        //win patterns in array. this is a set of sets.
        let winPatters: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        //remove all nils, and then filter out human moves
        let playerMoves = moves.compactMap{ $0 }.filter {$0.player == player }
        //go through all player moves and return board indexes
        let playerPositions = Set(playerMoves.map {$0.boardIndex})
        //iterate through win patters.
        for pattern in winPatters where pattern.isSubset(of: playerPositions) {
            return true
        }
        //no win condition
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        //run compact map to remove all nils. if count = 9 = draw.
        return moves.compactMap{ $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
    }
}

//create move logic
//enum to differentiate between human moves and computer moves
enum Player {
    case human, computer
}


//a move has a player. it has a position on the board. it has an indicator.
struct Move {
    //human or computer?
    let player: Player
    // index of board
    let boardIndex: Int
    //use xmark for human and circle for computer
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

