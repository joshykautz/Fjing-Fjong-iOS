//
//  PopUpViewController.swift
//  Fjing Fjong
//
//  Created by Fjorge Developers on 4/14/20.
//  Copyright © 2020 Fjorge. All rights reserved.
//

import UIKit
import CoreData
import SearchTextField

class PlayerPopUpViewController: UIViewController {
    
    var container: NSPersistentContainer!
    
    @IBOutlet weak var ConfirmButton: UIButton!
    
    @IBOutlet weak var playerOneSearchTextField: SearchTextField!
    @IBOutlet weak var playerTwoSearchTextField: SearchTextField!
    @IBOutlet weak var playerThreeSearchTextField: SearchTextField!
    @IBOutlet weak var playerFourSearchTextField: SearchTextField!
    
    var playerItems : [SearchTextFieldItem] = []
    var playerOneItems : [SearchTextFieldItem] = []
    var playerTwoItems : [SearchTextFieldItem] = []
    var playerThreeItems : [SearchTextFieldItem] = []
    var playerFourItems : [SearchTextFieldItem] = []
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ConfirmButton.isEnabled = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        container = appDelegate.persistentContainer
        
        let players = try! self.container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Player")) as! [Player]
        // TODO: Show loading indicator until Players are retrieved with images
        // TODO: If player.photo! is NIL then display loading indicator and try again in 1 second.

        for player in players {
            var imageData : Data? = nil
            let playerData = player.photo
            let defaultData = UIImage(named: "Player")?.pngData()
            if (playerData == nil){
                imageData = defaultData
            }
            else{
                imageData = playerData
            }
            playerItems.append(SearchTextFieldItem(title: player.name!, subtitle: String(format:"Rating: %.2f", player.rating), image: UIImage(data: imageData!)))
        }
        
        playerOneSearchTextField.startVisible = true
        playerOneSearchTextField.tableCornerRadius = 10
        playerOneSearchTextField.theme = SearchTextFieldTheme.darkTheme()
        playerOneSearchTextField.theme.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)!
        playerOneSearchTextField.theme.bgColor = UIColor (red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        playerOneSearchTextField.theme.borderColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerOneSearchTextField.theme.separatorColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerOneSearchTextField.theme.cellHeight = 80
        playerOneSearchTextField.itemSelectionHandler = { results, resultsIndex in
            self.playerOneSearchTextField.text = results[resultsIndex].title
            self.dismissKeyboard()
        }
        
        playerTwoSearchTextField.startVisible = true
        playerTwoSearchTextField.tableCornerRadius = 10
        playerTwoSearchTextField.theme = SearchTextFieldTheme.darkTheme()
        playerTwoSearchTextField.theme.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)!
        playerTwoSearchTextField.theme.bgColor = UIColor (red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        playerTwoSearchTextField.theme.borderColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerTwoSearchTextField.theme.separatorColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerTwoSearchTextField.theme.cellHeight = 80
        playerTwoSearchTextField.itemSelectionHandler = { results, resultsIndex in
            self.playerTwoSearchTextField.text = results[resultsIndex].title
            self.dismissKeyboard()
        }
        
        playerThreeSearchTextField.startVisible = true
        playerThreeSearchTextField.tableCornerRadius = 10
        playerThreeSearchTextField.theme = SearchTextFieldTheme.darkTheme()
        playerThreeSearchTextField.theme.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)!
        playerThreeSearchTextField.theme.bgColor = UIColor (red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        playerThreeSearchTextField.theme.borderColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerThreeSearchTextField.theme.separatorColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerThreeSearchTextField.theme.cellHeight = 80
        playerThreeSearchTextField.itemSelectionHandler = { results, resultsIndex in
            self.playerThreeSearchTextField.text = results[resultsIndex].title
            self.dismissKeyboard()
        }
        
        playerFourSearchTextField.startVisible = true
        playerFourSearchTextField.tableCornerRadius = 10
        playerFourSearchTextField.theme = SearchTextFieldTheme.darkTheme()
        playerFourSearchTextField.theme.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)!
        playerFourSearchTextField.theme.bgColor = UIColor (red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        playerFourSearchTextField.theme.borderColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerFourSearchTextField.theme.separatorColor = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        playerFourSearchTextField.theme.cellHeight = 80
        playerFourSearchTextField.itemSelectionHandler = { results, resultsIndex in
            self.playerFourSearchTextField.text = results[resultsIndex].title
            self.dismissKeyboard()
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
    }
    
    func updateSearchTextFieldItems(){
        self.playerOneItems = self.playerItems
        self.playerTwoItems = self.playerItems
        self.playerThreeItems = self.playerItems
        self.playerFourItems = self.playerItems
        
        // Remove Player One from each SearchTextField's filterItems if the Player One a valid player.
        let playerOne = self.playerOneItems.filter{ $0.title.lowercased() == self.playerOneSearchTextField.text!.lowercased() }.first
        if (playerOne != nil){
            let playerOneIndex = self.playerOneItems.firstIndex(where: { (item) -> Bool in
                item.title == playerOne!.title
            })
            
            self.playerOneItems.remove(at: playerOneIndex!)
            self.playerTwoItems.remove(at: playerOneIndex!)
            self.playerThreeItems.remove(at: playerOneIndex!)
            self.playerFourItems.remove(at: playerOneIndex!)
        }
        
        // Remove Player Two from each SearchTextField's filterItems if the Player Two a valid player.
        let playerTwo = self.playerTwoItems.filter{ $0.title.lowercased() == self.playerTwoSearchTextField.text!.lowercased() }.first
        if (playerTwo != nil){
            let playerTwoIndex = self.playerTwoItems.firstIndex(where: { (item) -> Bool in
                item.title == playerTwo!.title
            })
            
            self.playerOneItems.remove(at: playerTwoIndex!)
            self.playerTwoItems.remove(at: playerTwoIndex!)
            self.playerThreeItems.remove(at: playerTwoIndex!)
            self.playerFourItems.remove(at: playerTwoIndex!)
        }
        
        // Remove Player Three from each SearchTextField's filterItems if the Player Three a valid player.
        let playerThree = self.playerThreeItems.filter{ $0.title.lowercased() == self.playerThreeSearchTextField.text!.lowercased() }.first
        if (playerThree != nil){
            let playerThreeIndex = self.playerThreeItems.firstIndex(where: { (item) -> Bool in
                item.title == playerThree!.title
            })
            
            self.playerOneItems.remove(at: playerThreeIndex!)
            self.playerTwoItems.remove(at: playerThreeIndex!)
            self.playerThreeItems.remove(at: playerThreeIndex!)
            self.playerFourItems.remove(at: playerThreeIndex!)
        }
        
        // Remove Player Four from each SearchTextField's filterItems if the Player Four a valid player.
        let playerFour = self.playerFourItems.filter{ $0.title.lowercased() == self.playerFourSearchTextField.text!.lowercased() }.first
        if (playerFour != nil){
            let playerFourIndex = self.playerFourItems.firstIndex(where: { (item) -> Bool in
                item.title == playerFour!.title
            })
            
            self.playerOneItems.remove(at: playerFourIndex!)
            self.playerTwoItems.remove(at: playerFourIndex!)
            self.playerThreeItems.remove(at: playerFourIndex!)
            self.playerFourItems.remove(at: playerFourIndex!)
        }
    }
    
    func updateConfirmationButton(){
        print("Confirmation Button Updated.")
        let playerOne = self.playerItems.filter{ $0.title.lowercased() == self.playerOneSearchTextField.text!.lowercased() }.first
        let playerTwo = self.playerItems.filter{ $0.title.lowercased() == self.playerTwoSearchTextField.text!.lowercased() }.first
        let playerThree = self.playerItems.filter{ $0.title.lowercased() == self.playerThreeSearchTextField.text!.lowercased() }.first
        let playerFour = self.playerItems.filter{ $0.title.lowercased() == self.playerFourSearchTextField.text!.lowercased() }.first
        if (playerOne != nil && playerTwo != nil && playerThree != nil && playerFour != nil && arePlayersUnique()){
            ConfirmButton.isEnabled = true
        }
        else{
            ConfirmButton.isEnabled = false
        }
    }
    
    func arePlayersUnique() -> Bool {
        let one = self.playerOneSearchTextField.text!.lowercased()
        let two = self.playerTwoSearchTextField.text!.lowercased()
        let three = self.playerThreeSearchTextField.text!.lowercased()
        let four = self.playerFourSearchTextField.text!.lowercased()
        if (one == two || one == three || one == four ||
            two == one || two == three || two == four ||
            three == one || three == two || three == four ||
            four == one || four == two || four == three){
            print("Playes are NOT unique")
            return false
        }
        else {
            print("Playes are unique")
            return true
        }
    }
    
    @objc func dismissKeyboard() {
        playerOneSearchTextField.resignFirstResponder()
        playerTwoSearchTextField.resignFirstResponder()
        playerThreeSearchTextField.resignFirstResponder()
        playerFourSearchTextField.resignFirstResponder()
        
        updateSearchTextFieldItems()
        updateConfirmationButton()
        playerOneSearchTextField.filterItems([])
        playerTwoSearchTextField.filterItems([])
        playerThreeSearchTextField.filterItems([])
        playerFourSearchTextField.filterItems([])
    }
    
    @IBAction func EditingDidBegin(_ sender: Any) {
        print("Editing Did Begin: " + String((sender as! SearchTextField).tag))
        updateSearchTextFieldItems()
        updateConfirmationButton()
        playerOneSearchTextField.filterItems([])
        playerTwoSearchTextField.filterItems([])
        playerThreeSearchTextField.filterItems([])
        playerFourSearchTextField.filterItems([])
        
        if ((sender as! SearchTextField).tag == 1){
            playerOneSearchTextField.filterItems(self.playerOneItems)
        }
        if ((sender as! SearchTextField).tag == 2){
            playerTwoSearchTextField.filterItems(self.playerTwoItems)
        }
        if ((sender as! SearchTextField).tag == 3){
            playerThreeSearchTextField.filterItems(self.playerThreeItems)
        }
        if ((sender as! SearchTextField).tag == 4){
            playerFourSearchTextField.filterItems(self.playerFourItems)
        }
    }
    
    @IBAction func EditingDidEnd(_ sender: Any) {
        print("Editing Did End: " + String((sender as! SearchTextField).tag))
        updateSearchTextFieldItems()
        updateConfirmationButton()
        playerOneSearchTextField.filterItems([])
        playerTwoSearchTextField.filterItems([])
        playerThreeSearchTextField.filterItems([])
        playerFourSearchTextField.filterItems([])
    }
    
    @IBAction func EditingChanged(_ sender: Any) {
        print("Editing Changed: " + String((sender as! SearchTextField).tag))
        updateSearchTextFieldItems()
        updateConfirmationButton()
        playerOneSearchTextField.filterItems([])
        playerTwoSearchTextField.filterItems([])
        playerThreeSearchTextField.filterItems([])
        playerFourSearchTextField.filterItems([])
        
        if ((sender as! SearchTextField).tag == 1){
            playerOneSearchTextField.filterItems(self.playerOneItems)
        }
        if ((sender as! SearchTextField).tag == 2){
            playerTwoSearchTextField.filterItems(self.playerTwoItems)
        }
        if ((sender as! SearchTextField).tag == 3){
            playerThreeSearchTextField.filterItems(self.playerThreeItems)
        }
        if ((sender as! SearchTextField).tag == 4){
            playerFourSearchTextField.filterItems(self.playerFourItems)
        }
    }
    
    @IBAction func ConfirmButtonPressed(_ sender: Any) {
        // TODO: Display Score PopUpViewController
    }
    
    @IBAction func CloseButtonTouched(_ sender: Any) {
        self.dismiss(animated: true) {
            // Dismissed
        }
    }
}
