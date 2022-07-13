//
//  AllItemCategory.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/28.
//

import Foundation
import UIKit

//struct AllItem{
//    var money:String
//    var date:Date
//    var category:String
//    var source:String
//    var classification:String
//
//}
enum DateChoose:String{
    case Year
    case Month
    case Custom
}

enum ExpenseCategory: String, CaseIterable, Codable{
    case Food
    case Clothes
    case House
    case Traffic
    case Education
    case Entertainment
    case Other
    
    var color:UIColor{
        switch self {
        case .Food:
            return .systemIndigo
        case .Clothes:
            return UIColor(red: 0.625, green: 0.789, blue: 0.252, alpha: 1)
        case .House:
            return .systemOrange
        case .Traffic:
            return UIColor(red: 0.228, green: 0.839, blue: 0.907, alpha: 1)
        case .Education:
            return UIColor(red: 0.940, green: 0.375, blue: 0.428, alpha: 1)
        case .Entertainment:
            return UIColor(red: 0.283, green: 0.630, blue: 0.612, alpha: 1)
        case .Other:
            return UIColor(red: 0.673, green: 0.429, blue: 0.843, alpha: 1)
        }
    }
    
    
}

enum IncomeCategory: String, CaseIterable, Codable{
    case Salary
    case Bonus
    case Investment
    case OtherRevenue
    
    var color:UIColor{
        switch self {
        case .Salary:
            return UIColor(red: 0.825, green: 0, blue: 0.156, alpha: 1)
        case .Bonus:
            return UIColor(red: 0, green: 0.569, blue: 0, alpha: 1)
        case .Investment:
            return .systemBrown
        case .OtherRevenue:
            return UIColor(red: 0.826, green: 0.483, blue: 0.665, alpha: 1)
        }
    }
    
}

enum Account:String, CaseIterable, Codable{
    case Cash 
    case CreditCard
    case MobilePayment
    case Bank
    case Other
    
}
