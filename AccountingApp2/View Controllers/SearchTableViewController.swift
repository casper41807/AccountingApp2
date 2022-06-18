//
//  SearchTableViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/8.
//

import UIKit
import CoreData

class SearchTableViewController: UITableViewController,UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    var itemDatas = [ItemData]()
    var newItemDatas = [ItemData]()
    
    var itemDictionary = [Date:[ItemData]]()
    var itemDate = [Date]()
    
//    override func viewWillAppear(_ animated: Bool) {
//        filterItemDatas()
//    }
    
    //新增 search bar功能
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        //遵從 protocol UISearchResultsUpdating
        searchController.searchResultsUpdater = self

        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.tintColor = .black
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        searchController.searchBar.searchTextField.placeholder =  "金額,類別,來源,備註"
        navigationItem.searchController = searchController
        //畫面捲動時 search bar 將持續顯示在 navigation bar 上
        navigationItem.hidesSearchBarWhenScrolling = false
        //是否隱藏Navigation標題
        searchController.hidesNavigationBarDuringPresentation = false
        //搜尋欄右方是否加入CancelButton
        searchController.automaticallyShowsCancelButton  = false
       
        //  加入點擊畫面手勢
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.delegate = self
              //shouldReceiveTouch on UITableViewCellContentView
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        overrideUserInterfaceStyle = .light
        
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center //置中
        label.textColor = .white
        label.text = "搜尋"
        
        navigationItem.titleView = label
    
    }
    //手勢點選空白處收起searchBar鍵盤
    @objc func dismissKeyBoard(){
        searchController.searchBar.endEditing(true)
    }
    //實作 protocol UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text,
                  searchText.isEmpty == false  {
            // 透過AppDelegate取得資料
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                
            let predicate = NSPredicate(format: "category CONTAINS[c] %@ OR remark CONTAINS[c] %@ OR source CONTAINS[c] %@ OR money == %i" , "\(searchText)","\(searchText)","\(searchText)",(Int(searchText) ?? 0))
            // 建立Context
            let context = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<ItemData> = ItemData.fetchRequest()
            request.predicate = predicate
            do {
                itemDatas = try context.fetch(request)
            } catch {
                print("error")
            }
        }else{
            itemDatas = [ItemData]()
        }
        filterItemDatas()
        
        tableView.reloadData()
    }
    
    
    func numberFormatter(money:Int32)->String{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        formatter.maximumFractionDigits = 0
        let amountStr = formatter.string(from: NSNumber(value:money))!
        return amountStr
    }
    
    func filterItemDatas(){
        itemDictionary = [Date:[ItemData]]()
        itemDate = [Date]()
        
        newItemDatas = itemDatas.sorted(by: {
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
    
    @IBAction func unwindToSearchTableView(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.source is AddModificationViewController{
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            appDelegate.saveContext()
            tableView.reloadData()
        }
        // Use data from the view controller which initiated the unwind segue
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddModificationViewController,let section = tableView.indexPathForSelectedRow?.section,let row = tableView.indexPathForSelectedRow?.row{
            let itemdate = itemDate.sorted(by: {$0 < $1})
            let itemdatas = itemDictionary[itemdate[section]]
            controller.itemdata = itemdatas?[row]
            controller.num = 1
        }
    }
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return itemDate.count
//        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        let itemdate = itemDate.sorted(by: {$0 < $1})
        
        let date = itemdate[section]
        return itemDictionary[date]!.count
        
//        return itemDatas.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else{return UITableViewCell()}
        
        let itemdate = itemDate.sorted(by: {$0 < $1})
        
        let section = itemdate[indexPath.section]
        if let index = itemDictionary[section]{
            let row = index[indexPath.row]
            cell.moneyLabel.text = numberFormatter(money: row.money)
            cell.categoryImage.image = UIImage(named: row.category ?? "")
            cell.categoryLabel.text = row.category
            cell.accountLabel.text = row.source
            if row.classification == "支出"{
                cell.moneyLabel.textColor = .systemGreen
            }else{
                cell.moneyLabel.textColor = .red
            }
        }

        return cell
        
//        let index = itemDatas[indexPath.row]
//
//        cell.moneyLabel.text = numberFormatter(money: index.money)
//        cell.categoryLabel.text = index.category
//        cell.accountLabel.text = index.source
//        if index.classification == "支出"{
//            cell.moneyLabel.textColor = .systemGreen
//        }else{
//            cell.moneyLabel.textColor = .red
//        }
//        cell.categoryImage.image = UIImage(named:index.category ?? "")
//
//
//        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
       
        let itemdate = itemDate.sorted(by: {$0 < $1})
        let section = itemdate[indexPath.section]
        if let index = itemDictionary[section]{
            let row = index[indexPath.row]
            
            AccountingController.shared.deleteItem(id:row.imageStr ?? "")
            
            context.delete(row)
            itemDictionary[section]?.remove(at: indexPath.row)
            if itemDictionary[section]?.count == 0{
                itemDate = itemdate.filter({ Date in
                    Date != section
                })
                appDelegate.saveContext()
                tableView.beginUpdates()
                tableView.deleteSections([indexPath.section], with: .automatic)
                tableView.endUpdates()
                
            }else{
                appDelegate.saveContext()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadData()
            }
        }
    }
    
    
     
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    //滑動table view隱藏searchBar鍵盤
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let itemdate = itemDate.sorted(by: {$0 < $1})
        let index = itemdate[section]
        let calendar = Calendar.current
        let day = calendar.component(.day, from: index)
        let month = calendar.component(.month, from: index)
        let year = calendar.component(.year, from: index)

        return "\(year)年\(month)月\(day)日"
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goAlteration", sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
        
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
