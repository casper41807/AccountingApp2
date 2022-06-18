//
//  MainTableViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/27.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {
 
    @IBOutlet weak var MainDatePicker: UIDatePicker!
    
    var container: NSPersistentContainer!
    var itemDatas = [ItemData]()
    
   
    
//    var allItemsDate = [[AllItem]]()
//    var allItems = [AllItem]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        searchLocationForDate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getItemDatas()
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center //置中
        label.textColor = .white
        label.text = "簡易記帳"
        
        navigationItem.titleView = label
        
        overrideUserInterfaceStyle = .light
    }
    
    func numberFormatter(money:Int32)->String{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        formatter.maximumFractionDigits = 0
        let amountStr = formatter.string(from: NSNumber(value:money))!
        return amountStr
    }
    
    func getItemDatas() {
        
        let context = container.viewContext
        do {
            itemDatas = try context.fetch(ItemData.fetchRequest())
        } catch {
            print("error")
        }
    }
    
    func searchLocationForDate() {
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: MainDatePicker.date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        let context = container.viewContext
        let request: NSFetchRequest<ItemData> = ItemData.fetchRequest()
        request.predicate = predicate
        do {
            itemDatas = try context.fetch(request)
        } catch {
            print("error")
        }
        tableView.reloadData()
    }
    
    
    @IBAction func selectDate(_ sender: UIDatePicker) {
        searchLocationForDate()
    }
    
    
    @IBAction func unwindToMaimTableView(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? AddModificationViewController,let itemdata = sourceViewController.itemdata{
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/dd/MM"
            
            if tableView.indexPathForSelectedRow != nil{
//                itemDatas[indexPath.row] = itemdata
                print("更改成功")
//                allItems[indexPath.row] = allItem
//                tableView.reloadRows(at: [indexPath], with: .automatic)
            }else{
                //其實已經coreData新增成功 但為了讓表格更新寫了以下
                if dateFormatter.string(from: itemdata.date!)
                     == dateFormatter.string(from: MainDatePicker.date){
                    itemDatas.insert(itemdata, at: 0)
                    print("表格新增成功")
                }
                
                print("新增成功")
//                allItems.insert(allItem, at: 0)
//                tableView.reloadData()
            }
            container.saveContext()
            tableView.reloadData()
            print("貯存")
            
        }
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddModificationViewController,let row = tableView.indexPathForSelectedRow?.row{
            controller.itemdata = itemDatas[row]
            controller.num = 0
//            controller.allItem = allItems[row]
            print(row)
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemDatas.count
//        return allItems.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else{return UITableViewCell()}
        
        let index = itemDatas[indexPath.row]
//        let index = allItems[indexPath.row]
        
        cell.moneyLabel.text = numberFormatter(money: index.money)
        cell.categoryLabel.text = index.category
        cell.accountLabel.text = index.source
        if index.classification == "支出"{
            cell.moneyLabel.textColor = .systemGreen
        }else{
            cell.moneyLabel.textColor = .red
        }
        cell.categoryImage.image = UIImage(named:index.category ?? "")
//        cell.moneyLabel.text = index.money
//        cell.CategoryLabel.text = index.category
//        cell.AccountLabel.text = index.source
//        if index.classification == "支出"{
//            cell.moneyLabel.textColor = .systemGreen
//        }else{
//            cell.moneyLabel.textColor = .red
//        }
//        cell.CategoryImage.image = UIImage(named:index.category )

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if itemDatas.isEmpty == true {
            return "點選右上角 '＋' 新增些紀錄吧!!"
        }else{
            var totalExpenseMoney:Int32 = 0
            var totalIncomeMoney:Int32 = 0
            itemDatas.forEach { ItemData in
                if ItemData.classification == "支出"{
                    totalExpenseMoney += ItemData.money
                }else{
                    totalIncomeMoney += ItemData.money
                }
            }
            let total = "支出總額:\(numberFormatter(money: totalExpenseMoney))\n收入總額:\(numberFormatter(money: totalIncomeMoney))"
            
            return total
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textAlignment = .right
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = container.viewContext
        let itemsData = itemDatas[indexPath.row]
        
        AccountingController.shared.deleteItem(id:itemsData.imageStr ?? "")
        
        context.delete(itemsData)
        itemDatas.remove(at: indexPath.row)
        container.saveContext()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        
        
        
//        allItems.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

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
