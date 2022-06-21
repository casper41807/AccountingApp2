//
//  ChooseDateViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/2.
//

import UIKit

protocol SentBackData{
    func dismissback(date:Date,num:Int)
    func dismissbackStartEnd(start:Date,end:Date,num:Int)
}

protocol SentBackStartEndDate{
    func dissmissbackStartEnd(start:Date,end:Date)
}

class ChooseDateViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
   
    @IBOutlet weak var chooseTextField: UITextField!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var confirmOutlet: UIButton!
    
    @IBOutlet var startDatePicker: UIDatePicker!
    
    
    @IBOutlet weak var showLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var segmentedOutlet: UISegmentedControl!
    
    @IBOutlet weak var selfStack: UIStackView!
    
    let years = [2017,2018,2019,2020,2021,2022,2023,2024,2025,2026,2027,2028]
    let months = [1,2,3,4,5,6,7,8,9,10,11,12]
    let engMonths = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    let dateFormatter = DateFormatter()
    
    var startDate:Date?
    var endDate:Date?
    var isStart:Bool?
    
    var delegate:SentBackData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker.isHidden = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
        confirmOutlet.setTitle(NSLocalizedString("confirm", comment: ""), for: .normal)
        confirmOutlet.layer.cornerRadius = 5
    
        overrideUserInterfaceStyle = .light
    }
    
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            showLabel.text = NSLocalizedString("Select Year", comment: "")
            pickerView.reloadAllComponents()
            pickerView.isHidden = false
            selfStack.isHidden = true
            chooseTextField.text = ""
            chooseTextField.isHidden = false
            startDatePicker.isHidden = true
           
            
        case 1:
            showLabel.text = NSLocalizedString("Select Month", comment: "")
            pickerView.reloadAllComponents()
            pickerView.isHidden = false
            selfStack.isHidden = true
            chooseTextField.text = ""
            chooseTextField.isHidden = false
            startDatePicker.isHidden = true
            
            
            
        default:
            showLabel.text = NSLocalizedString("Custom Date", comment: "")
            pickerView.isHidden = true
            selfStack.isHidden = false
            chooseTextField.isHidden = true
            startDatePicker.isHidden = false
            
            
        }
    }
    
    @IBAction func startDateAction(_ sender: UIButton) {
        isStart = true
//        startDatePicker.isHidden = false

    }
    
    
    @IBAction func endDateAction(_ sender: Any) {
        isStart = false


    }
    
    
    @IBAction func startDatePickerAction(_ sender: UIDatePicker) {
        dateFormatter.dateFormat = NSLocalizedString("MMM d, yyyy", comment: "")
        if isStart == true{
            startDateButton.setTitle(dateFormatter.string(from: sender.date), for: .normal)
            
            let calender = Calendar.current

            var dateComponents = calender.dateComponents([.year, .month, .day], from: startDatePicker.date)
            dateComponents.timeZone = NSTimeZone.system
            startDate = calender.date(from: dateComponents)
        }else{
            
            endDateButton.setTitle(dateFormatter.string(from: sender.date), for: .normal)
            
            let calender = Calendar.current

            var dateComponents = calender.dateComponents([.year, .month, .day], from: startDatePicker.date)
            dateComponents.timeZone = NSTimeZone.system
            endDate = calender.date(from: dateComponents)
        }
        
    }
    
    
    
    
    
    @IBAction func dissMissBackButton(_ sender: UIButton) {
        switch segmentedOutlet.selectedSegmentIndex{
        case 0:
            let row = pickerView.selectedRow(inComponent: 0)
            let dateComponents = DateComponents(calendar: Calendar.current,year: years[row], month: 1 )
            if let date = dateComponents.date{
                delegate?.dismissback(date: date,num:0)
                dismiss(animated: true)
                print("成功更改年份")
            }
            
        case 1:
            
            let year =  Calendar.current.component(.year, from: Date())
            let row = pickerView.selectedRow(inComponent: 0)
            let dateComponents = DateComponents(calendar: Calendar.current,year: year, month: months[row] )
            if let date = dateComponents.date{
                delegate?.dismissback(date: date,num:1)
                dismiss(animated: true)
                print("成功更改月份")
            }
        default:
            
            
//            let startYear =  Calendar.current.component(.year, from: startDatePicker.date)
//            let startMonth =  Calendar.current.component(.month, from: startDatePicker.date)
//            let startDay = Calendar.current.component(.day, from: startDatePicker.date)
//            let startDateComponents = DateComponents(calendar: Calendar.current,year: startYear, month: startMonth,day: startDay )
//            let startDate = startDateComponents.date
//            print(startDate)
            if startDate != nil && endDate != nil{
                if startDate?.compare(endDate!) == .orderedAscending{
                    delegate?.dismissbackStartEnd(start: startDate!, end: endDate!,num: 2)
                    dismiss(animated: true)
                }else{
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please check that the date is entered correctly", comment: ""), preferredStyle: .alert)
                    let action = UIAlertAction(title: "ok", style: .default)
                    alert.addAction(action)
                    present(alert, animated: true)
                }
            }else{
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please check that the date is entered correctly", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default)
                alert.addAction(action)
                present(alert, animated: true)
            }
            
           
        }
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch segmentedOutlet.selectedSegmentIndex{
        case 0:
            return years.count
        case 1:
            return months.count
        default:
            return 0
        }
       
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch segmentedOutlet.selectedSegmentIndex{
        case 0:
            return "\(years[row])"
        case 1:
            return NSLocalizedString("\(engMonths[row])", comment: "")
//            "\(months[row])月"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        
        switch segmentedOutlet.selectedSegmentIndex{
        case 0:
            chooseTextField.text = "\(years[row])"
        case 1:
            chooseTextField.text = "\(year)," + NSLocalizedString("\(engMonths[row])", comment: "") 
        default:
            return
        }
       
//        view.endEditing(true)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
