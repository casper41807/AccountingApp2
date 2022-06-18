//
//  ChartsTableViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/30.
//

import UIKit
import CoreData
import Charts

class ChartsTableViewController: UITableViewController,SentBackData {

    @IBOutlet weak var categorySegmented: UISegmentedControl!
    
    
    @IBOutlet weak var viewForCharts: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    let expenseCategory = ExpenseCategory.allCases
    let incomeCategory = IncomeCategory.allCases
    
    var container: NSPersistentContainer!
    var itemDatas = [ItemData]()
    var num = 1
    var today = Date()
    
    var start = Date()
    var end = Date()
    
   
    override func viewWillAppear(_ animated: Bool) {
        
        if num == 2{
            customizeDate()
        }else{
            currentMonth()
        }
        
        
        if categorySegmented.selectedSegmentIndex == 0{
            setExpenseChartView()
        }else{
            setIncomeChartView()
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        overrideUserInterfaceStyle = .light
        
//        viewForCharts.translatesAutoresizingMaskIntoConstraints = false
//        tableView.addSubview(viewForCharts)
//        viewForCharts.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
//        viewForCharts.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
//        viewForCharts.topAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor).isActive = true
//
//        viewForCharts.heightAnchor.constraint(equalToConstant: 360).isActive = true
    }
    
    //生成支出項目數據 DataEntry
    func setExpenseChartView() {
        
        let expensecategory = expenseCategory.filter { ExpenseCategory in
            calculateExpenseSum(category: ExpenseCategory) != 0
        }
        
        let pieChartDataEntries = expensecategory.map{(category)->PieChartDataEntry in
            return PieChartDataEntry(value: Double(calculateExpenseSum(category: category)), label: category.rawValue)
        }
        
        
        //設定項目 DataSet
        let dataSet = PieChartDataSet(entries: pieChartDataEntries, label: "")
        // 設定項目顏色
        dataSet.colors = expensecategory.map{ (category)->UIColor in
            return UIColor(named: "\(category)Color") ?? UIColor.white
        }
        // 點選後突出距離
        dataSet.selectionShift = 7
        // 圓餅分隔間距
        dataSet.sliceSpace = 3
        // 不顯示數值
//        dataSet.drawValuesEnabled = false
        dataSet.valueTextColor = .black
        dataSet.entryLabelColor = .black
        
        //設定資料 Data
        let data = PieChartData(dataSet: dataSet)

        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
//        pFormatter.zeroSymbol = ""
       
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
       
        pieChartView.usePercentValuesEnabled = true
        
        pieChartView.data = data
        
        let totalAmount = itemDatas.reduce(0,{if $1.classification == "支出"{
            return $0+Int($1.money) };return $0})
        
        
        if pieChartDataEntries.isEmpty == true{
            pieChartView.centerText = "查無資料"
        }else{
            pieChartView.centerText = "支出總和\n$\(numberFormatter(money: Int32(totalAmount)))"
        }
        
        let legend = pieChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        //動畫
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    
    
    //生成收入項目數據 DataEntry
    func setIncomeChartView() {
        
        let incomecategory = incomeCategory.filter { IncomeCategory in
            calculateIncomeSum(category: IncomeCategory) != 0
        }
        
        let pieChartDataEntries = incomecategory.map{(category)->PieChartDataEntry in
            return PieChartDataEntry(value: Double(calculateIncomeSum(category: category)), label: category.rawValue)
        }
        //設定項目 DataSet
        let dataSet = PieChartDataSet(entries: pieChartDataEntries, label: "")
        // 設定項目顏色
        dataSet.colors = incomecategory.map{ (category)->UIColor in
            return UIColor(named: "\(category)Color") ?? UIColor.white
        }
        // 點選後突出距離
        dataSet.selectionShift = 7
        // 圓餅分隔間距
        dataSet.sliceSpace = 3
        // 不顯示數值
//        dataSet.drawValuesEnabled = false
        dataSet.valueTextColor = .black
        dataSet.entryLabelColor = .black
        
        //設定資料 Data
        let data = PieChartData(dataSet: dataSet)

        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
//        pFormatter.zeroSymbol = ""
       
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
       
        pieChartView.usePercentValuesEnabled = true
        
        pieChartView.data = data
    
        let totalAmount = itemDatas.reduce(0,{if $1.classification == "收入"{
            return $0+Int($1.money) };return $0})
        
        if pieChartDataEntries.isEmpty == true{
            pieChartView.centerText = "查無資料"
        }else{
            pieChartView.centerText = "收入總和\n$\(numberFormatter(money: Int32(totalAmount)))"
        }
        
        
        let legend = pieChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        //動畫
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    //只抓取計當月的資料
    func currentMonth() {
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: today)
        let year = calendar.component(.year, from: today)
        print(month)
        print(year)
        
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: 1)
        
        let startDate = dateComponents.date
        if num == 0{
            let endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)!
            let predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate! as NSDate , endDate as NSDate)
            let context = container.viewContext
            let request: NSFetchRequest<ItemData> = ItemData.fetchRequest()
            request.predicate = predicate
            do {
                itemDatas = try context.fetch(request)
            } catch {
                print("error")
            }
        }else{
            let endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)!
            let predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate! as NSDate , endDate as NSDate)
            let context = container.viewContext
            let request: NSFetchRequest<ItemData> = ItemData.fetchRequest()
            request.predicate = predicate
            do {
                itemDatas = try context.fetch(request)
            } catch {
                print("error")
            }
        }
        
        tableView.reloadData()
    }
    
    func dismissback(date:Date,num:Int){
        today = date
        self.num = num
        
        currentMonth()
        if categorySegmented.selectedSegmentIndex == 0{
            setExpenseChartView()
           
        }else{
            setIncomeChartView()
           
        }
        tableView.reloadData()
    }
    
    
    func customizeDate(){
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate , end as NSDate)
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
    
    
    
    func dismissbackStartEnd(start: Date, end: Date, num:Int) {
        self.start = start
        self.end = end
        self.num = num
        
        customizeDate()
        if categorySegmented.selectedSegmentIndex == 0{
            setExpenseChartView()
        }else{
            setIncomeChartView()
        }
        tableView.reloadData()
    }
    
    
//    func getItemDatas() {
//
//        let context = container.viewContext
//        do {
//            itemDatas = try context.fetch(ItemData.fetchRequest())
//        } catch {
//            print("error")
//        }
//    }
    
    func numberFormatter(money:Int32)->String{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        formatter.maximumFractionDigits = 0
        let amountStr = formatter.string(from: NSNumber(value:money))!
        return amountStr
    }
    
//    func calculateSum(category:String)->Int32 {
//        let totalAmount = itemDatas.reduce(0,{if $1.category == category{
//            return $0+Int($1.money) };return $0})
//        return Int32(totalAmount)
//    }
    
    func calculateExpenseSum(category:ExpenseCategory)->Int32 {
        let totalMoney = itemDatas.reduce(0,{if $1.category == category.rawValue{
            return $0+Int($1.money) };return $0})
        return Int32(totalMoney)
    }
    
    func calculateIncomeSum(category:IncomeCategory)->Int32 {
        let totalMoney = itemDatas.reduce(0,{if $1.category == category.rawValue{
            return $0+Int($1.money) };return $0})
        return Int32(totalMoney)
    }
    
    @IBAction func categoryButton(_ sender: UISegmentedControl) {
        if num == 2{
            customizeDate()
        }else{
            currentMonth()
        }
        if categorySegmented.selectedSegmentIndex == 0{
            setExpenseChartView()
        }else{
            setIncomeChartView()
        }
        tableView.reloadData()
    }
    
    @IBAction func chooseDateButton(_ sender: UIBarButtonItem) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChooseDateViewController") as? ChooseDateViewController
            ,let sheetPresentationController = controller.sheetPresentationController{
            
            controller.delegate = self
            sheetPresentationController.detents = [.medium()]
                sheetPresentationController.prefersGrabberVisible = true
                present(controller, animated: true, completion: nil)
            
        }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy年M月d日"
        
//        let alert = UIAlertController(title: "自定義日期", message: "選擇日期範圍", preferredStyle: .alert)
//
//        alert.addTextField{ textField in
//            textField.placeholder = "起始時間"
//            textField.inputView = self.startDatePicker
//            textField.text = dateFormatter.string(from: self.startDatePicker.date)
//        }
//        alert.addTextField{ textField in
//            textField.placeholder = "結束時間"
//            textField.inputView = self.endDatePicker
//            textField.text = dateFormatter.string(from: self.endDatePicker.date)
//        }
//
//        let okAction = UIAlertAction(title: "確認", style: .default) { _ in
//            let startDate = alert.textFields?[0].text
//            let endDate = alert.textFields?[1].text
//        }
//        let cancelAction = UIAlertAction(title: "取消", style:.default)
//        alert.addAction(okAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DetailTableViewController,let row = tableView.indexPathForSelectedRow?.row{
            controller.itemDatas = itemDatas
            controller.row = row
            controller.SegmentIndex = categorySegmented.selectedSegmentIndex
        }
    }
  
    @IBSegueAction func goToDetail(_ coder: NSCoder) -> DetailTableViewController? {
        let controller = DetailTableViewController(coder: coder)
        controller?.itemDatas = itemDatas
        if let row = tableView.indexPathForSelectedRow?.row{
            controller?.row = row
        }
        controller?.SegmentIndex = categorySegmented.selectedSegmentIndex
        
        return controller
    }
    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//
//    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if categorySegmented.selectedSegmentIndex == 0{
            return expenseCategory.count
        }else{
            return incomeCategory.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartsTableViewCell", for: indexPath) as? ChartsTableViewCell else{return UITableViewCell()}
        
        if categorySegmented.selectedSegmentIndex == 0{
            let index = expenseCategory[indexPath.row]
        
            cell.categoryImage.image = UIImage(named: index.rawValue)
            cell.categoryLabel.text = index.rawValue
            cell.totalLabel.text = numberFormatter(money: calculateExpenseSum(category: index))
            
            var sum:Int32 = 0
            expenseCategory.forEach { ExpenseCategory in
                 sum += calculateExpenseSum(category: ExpenseCategory)
            }
            let percent = Double(calculateExpenseSum(category: index))/Double(sum)*100
            
            if percent.isNaN == true{
                cell.percentLabel.text = "0%"
            }else{
                if percent.truncatingRemainder(dividingBy: 1) == 0{
                    cell.percentLabel.text = "\(Int(percent))%"
                }else{
                    cell.percentLabel.text = "\(percent.rounding(toDecimal: 1))%"
                }
            }
            print(percent)
        }else{
            let index = incomeCategory[indexPath.row]
            
            cell.categoryImage.image = UIImage(named: index.rawValue)
            cell.categoryLabel.text = index.rawValue
            cell.totalLabel.text = numberFormatter(money: calculateIncomeSum(category: index))
            
            var sum:Int32 = 0
            incomeCategory.forEach { IncomeCategory in
                 sum += calculateIncomeSum(category: IncomeCategory)
            }
            let percent = Double(calculateIncomeSum(category: index))/Double(sum)*100
            if percent.isNaN == true{
                cell.percentLabel.text = "0%"
            }else{
                if percent.truncatingRemainder(dividingBy: 1) == 0{
                    cell.percentLabel.text = "\(Int(percent))%"
                }else{
                    cell.percentLabel.text = "\(percent.rounding(toDecimal: 1))%"
                }
            }
                
            
            
            print(percent)
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textAlignment = .right
        header.textLabel?.font = .systemFont(ofSize: 15)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: today)
        let year = calendar.component(.year, from: today)
        
        let startYear = calendar.component(.year, from: start)
        let startMonth = calendar.component(.month, from: start)
        let startDay = calendar.component(.day, from: start)
        
        let endYear = calendar.component(.year, from: end)
        let endMonth = calendar.component(.month, from: end)
        let endDay = calendar.component(.day, from: end)
        
        
        if categorySegmented.selectedSegmentIndex == 0{
            if num == 0{
                return "\(year)年  支出總金額"
            }else if num == 1{
                return "\(year)年\(month)月  支出總金額"
            }else{
                return "\(startYear)年\(startMonth)月\(startDay)日 ~ \(endYear)年\(endMonth)月\(endDay)日  支出總金額"
            }
            
        }else{
            if num == 0{
                return "\(year)年  收入總金額"
            }else if num == 1{
                return "\(year)年\(month)月  收入總金額"
            }else{
                return "\(startYear)年\(startMonth)月\(startDay)日 ~ \(endYear)年\(endMonth)月\(endDay)日  收入總金額"
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categorySegmented.selectedSegmentIndex == 0{
            let index = expenseCategory[indexPath.row]
            if calculateExpenseSum(category: index) == 0{
                tableView.deselectRow(at: indexPath, animated: false)
            }else{
                performSegue(withIdentifier: "goToDetail", sender: nil)
            }
            
            
        }else{
            let index = incomeCategory[indexPath.row]
            if calculateIncomeSum(category: index) == 0{
                tableView.deselectRow(at: indexPath, animated: false)
            }else{
                performSegue(withIdentifier: "goToDetail", sender: nil)
            }
           
        }
    }
    
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//         return viewForCharts
//    }
//
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50

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

//class DigitValueFormatter: NSObject, ValueFormatter {
//    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
//        let valueWithoutDecimalPart = String(format: "%.1f%%", value)
//        return valueWithoutDecimalPart
//    }
//}

extension Double {
    func rounding(toDecimal decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}
