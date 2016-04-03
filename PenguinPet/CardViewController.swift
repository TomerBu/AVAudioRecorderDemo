//
//  CardViewController.swift
//  PenguinPet
//
//  Created by Tomer Buzaglo on 30/03/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    @IBOutlet weak var card1: UIButton!
    @IBOutlet weak var card2: UIButton!
    @IBOutlet weak var card3: UIButton!
    @IBOutlet weak var card4: UIButton!
    @IBOutlet weak var card5: UIButton!
    @IBOutlet weak var card6: UIButton!
    
    lazy var cards:[UIImage] = {
        //4_of_diamonds
        let suits = ["diamonds", "clubs" ,"spades", "hearts"]
        var ranks = [String]()
        for i in 2...10{
            ranks.append(i.description)
        }
        ranks += ["jack","queen", "king", "ace"]
        
        var cards = [UIImage(named: "black_joker")!, UIImage(named: "red_joker")!]
        
        for rank in ranks{
            for suit in suits{
                let image = UIImage(named: "\(rank)_of_\(suit)")!
                cards.append(image)
            }
        }
        return cards
    }()
    
    lazy var chosenCards:[UIImage] = {
        var chosenCards = [UIImage]()
        
        for _ in 1...3{
            let rand = Int(arc4random_uniform(UInt32(self.cards.count)))
            chosenCards.append(self.cards[rand])
        }
        chosenCards += chosenCards
        for _ in 1...3{
            chosenCards.sortInPlace{_ in
                return arc4random_uniform(UInt32(self.cards.count)) % 2 == 0
            }
        }
        return chosenCards
    }()
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let buttons = [card1, card2, card3, card4, card5, card6]
        for (idx, btn) in buttons.enumerate(){
            btn.setBackgroundImage(chosenCards[idx], forState: UIControlState.Highlighted.union(.Selected))
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
