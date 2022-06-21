//
//  AllItemCategory.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/28.
//

import Foundation

struct AllItem{
    var money:String
    var date:Date
    var category:String
    var source:String
    var classification:String
    
}


enum ExpenseCategory: String, CaseIterable, Codable{
    case Food
    case Clothes
    case House
    case Traffic
    case Education
    case Entertainment
    case Other
}

enum IncomeCategory: String, CaseIterable, Codable{
    case Salary
    case Bonus
    case Investment
    case OtherRevenue
}

enum Account:String, CaseIterable, Codable{
    case Cash 
    case CreditCard
    case MobilePayment
    case Bank
    case Other
    
}
