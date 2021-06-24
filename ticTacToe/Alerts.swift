//
//  Alerts.swift
//  ticTacToe
//
//  Created by Travis Moody on 6/21/21.
//

import SwiftUI

struct AlertItem: Identifiable {
    
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
    
}

struct AlertContext {
    
    static let humanWin = AlertItem(title: Text("You WIN!"),
                                    message: Text("YOU ARE SMART"), buttonTitle: Text("VICTORY"))
    
    static let computerWin = AlertItem(title: Text("You LOSE!"),
                                       message: Text("EMBARASSING!"), buttonTitle: Text("OUCH!"))
    
    static let draw = AlertItem(title: Text("NO ONE WINS!"),
                                message: Text("MEH!"), buttonTitle: Text("TRY AGAIN!"))
    
}
