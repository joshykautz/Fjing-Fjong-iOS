//
//  Token+CoreDataProperties.swift
//  
//
//  Created by Fjorge Developers on 4/15/20.
//
//

import Foundation
import CoreData


extension Token {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Token> {
        return NSFetchRequest<Token>(entityName: "Token")
    }

    @NSManaged public var value: String?

}
