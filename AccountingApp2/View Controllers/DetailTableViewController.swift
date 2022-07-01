//
//  DetailTableViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/4.
//

import UIKit

class DetailTableViewController: UITableViewController {

    var itemDatas = [ItemData]()
    var newItemDatas = [ItemData]()

    var itemDictionary = [Date:[ItemData]]()
    var itemDate = [Date]()
    
    var row = 0
    var SegmentIndex = 0
    
    let expenseCategory = ExpenseCategory.allCases
    let incomeCategory = IncomeCategory.allCases
    
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        filterItemDatas()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("\(expenseCategory[row].rawValue)", comment: "")
        overrideUserInterfaceStyle = .light
    }
    
    func filterItemDatas(){
        if SegmentIndex == 0{
            
            itemDictionary = [Date:[ItemData]]()
            itemDate = [Date]()
            
            newItemDatas = itemDatas.filter { ItemData in
                ItemData.category == "\(expenseCategory[row].rawValue)"
            }.sorted(by: {
                $0.date! < $1.date!
            })
            newItemDatas.forEach { ItemData in
                let calendar = Calendar.current
                let day = calendar.component(.day, from: ItemData.date!)
                let month = calendar.component(.month, from: ItemData.date!)
                let year = calendar.component(.year, from: ItemData.date!)
                let dateComponents = DateComponents(calendar: Calendar.current,  year: year, month: month, day: day)
                let date = dateComponents.date
                if itemDictionary[date!] == nil{
                    itemDictionary[date!] = [ItemData]
                }else{
                    itemDictionary[date!]?.append(ItemData)
                }
            }
            for i in itemDictionary.keys{
                itemDate.append(i)
            }
        }else{
            itemDictionary = [Date:[ItemData]]()
            itemDate = [Date]()
            
            newItemDatas = itemDatas.filter { ItemData in
                ItemData.category == "\(incomeCategory[row].rawValue)"
            }.sorted(by: {
                $0.date! < $1.date!
            })
            newItemDatas.forEach { ItemData in
                let calendar = Calendar.current
                let day = calendar.component(.day, from: ItemData.date!)
                let month = calendar.component(.month, from: ItemData.date!)
                let year = calendar.component(.year, from: ItemData.date!)
                let dateComponents = DateComponents(calendar: Calendar.current,  year: year, month: month, day: day)
                let date = dateComponents.date
                if itemDictionary[date!] == nil{
                    itemDictionary[date!] = [ItemData]
                }else{
                    itemDictionary[date!]?.append(ItemData)
                }
            }
            for i in itemDictionary.keys{
                itemDate.append(i)
            }
        }
    }
    
    func numberFormatter(money:Int32)->String{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        formatter.maximumFractionDigits = 0
        let amountStr = formatter.string(from: NSNumber(value:money))!
        return amountStr
    }
    
//    func getSection()->[Date]{
//        for i in itemDictionary.keys{
//             itemDate.append(i)
//        }
//        return itemDate
//    }
//    
//    func getRow(date:Date)->[ItemData]{
//        itemDictionary[date]
//    }
    
    
    
    
    @IBSegueAction func showDetail(_ coder: NSCoder) -> ShowDetailViewController? {
        let controller = ShowDetailViewController(coder: coder)
        if let section = tableView.indexPathForSelectedRow?.section,let row = tableView.indexPathForSelectedRow?.row{
            
            let itemdate = itemDate.sorted(by: {$0 < $1})
            let itemdatas = itemDictionary[itemdate[section]]
            controller?.itemdata = itemdatas?[row]
//            controller?.itemdata = newItemDatas[section]
        }
        
        
        return controller
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return itemDate.count
//        return newItemDatas.count

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let itemdate = itemDate.sorted(by: {$0 < $1})
        
        let date = itemdate[section]
        return itemDictionary[date]!.count
//        return 1

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetaiTableViewCell", for: indexPath) as? DetaiTableViewCell else {return UITableViewCell()}

        
        let itemdate = itemDate.sorted(by: {$0 < $1})
        
        let section = itemdate[indexPath.section]
        if let index = itemDictionary[section]{
            let row = index[indexPath.row]
            cell.moneyLabel.text = numberFormatter(money: row.money)
            cell.categoryImage.image = UIImage(named: row.category ?? "")
            cell.categoryLabel.text = NSLocalizedString("\(row.category!)", comment: "")
            cell.accountLabel.text = NSLocalizedString("\(row.source!)", comment: "")
            if row.classification == "Expense"{
                cell.moneyLabel.textColor = .systemGreen
            }else{
                cell.moneyLabel.textColor = .red
            }
        }

        return cell
        
//        let index = newItemDatas[indexPath.section]
//
//        cell.moneyLabel.text = numberFormatter(money: index.money)
//        cell.categoryImage.image = UIImage(named: index.category ?? "")
//        cell.categoryLabel.text = index.category
//        cell.accountLabel.text = index.source
//        if index.classification == "支出"{
//            cell.moneyLabel.textColor = .systemGreen
//        }else{
//            cell.moneyLabel.textColor = .red
//        }
//
//        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let itemdate = itemDate.sorted(by: {$0 < $1})
        let index = itemdate[section]
//        let index = newItemDatas[section]
//        let indexDate = index.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("MMM d, yyyy", comment: "")
        
        return "\(dateFormatter.string(from: index))"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 25
//
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
