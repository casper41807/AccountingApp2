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
    case food = "飲食"
    case clothes = "服飾"
    case house = "房屋"
    case transportation = "交通"
    case education = "教育"
    case entertainment = "娛樂"
    case other = "其他"
}

enum IncomeCategory: String, CaseIterable, Codable{
    case salary = "薪水"
    case bonus = "獎金"
    case investment = "投資"
    case otherIncom = "非法"
}

enum Account:String, CaseIterable, Codable{
    case cash = "現金"
    case creditCard = "信用卡"
    case mobilePayment = "行動支付"
    case bank = "銀行"
    case other = "其他"
    
}
