//
//  AddModificationViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/27.
//

import UIKit
import CoreData
import PhotosUI
import Kingfisher
import Network
import SwiftUI

class AddModificationViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    @IBOutlet weak var categoryOutlet: UIButton!
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var classificationOutlet: UILabel!
    @IBOutlet var sourcePicker: UIPickerView!
    @IBOutlet weak var remarkTextView: UITextView!

    @IBOutlet weak var photoOutlet: UIButton!
    @IBOutlet weak var photoActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var okOutlet: UIBarButtonItem!
    
    @IBOutlet weak var stackViewData: UIStackView!
    
    
    //判斷哪一頁面要修改資料
    var num = 0
    //接受上一頁傳來的項目
    var itemdata:ItemData?
//    var allItem:AllItem?
    //暫存照片的UIImage
    var previewImage:UIImage?
    //判斷是否新增選擇照片
    var selectPhoto = false
    //在textView裡增加預設字體
    var placeholder = UILabel()
    //紀錄airTable回傳資料id
    var imageStr:String?
    //判斷是否有網路
    let monitor = NWPathMonitor()
    var interNet:Bool?
    let noConnection = UILabel()
    
    let account = Account.allCases
    let expenseCategory = ExpenseCategory.allCases
    let incomeCategory = IncomeCategory.allCases
    
    
    
    
    //點空白處離開鍵盤
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitor.pathUpdateHandler = {  path in
            if path.status == .satisfied {
                self.interNet = true
                
                print("connection")
            } else {
                self.interNet = false
               
                print("no connection")
             
            }
        }
        monitor.start(queue: DispatchQueue.global())
        
    
        photoOutlet.imageView?.contentMode = .scaleAspectFit
        
        overrideUserInterfaceStyle = .light
        
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center //置中
        label.textColor = .white
        label.text = NSLocalizedString("Add", comment: "")
        
        navigationItem.titleView = label
        navigationItem.backButtonTitle = NSLocalizedString("Add", comment: "")
        
        noConnection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noConnection)
        
//        noConnection.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        noConnection.heightAnchor.constraint(equalToConstant: 50).isActive = true
        noConnection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noConnection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noConnection.numberOfLines = 0
        noConnection.text = NSLocalizedString("No internet connection,Please try again", comment: "")
        noConnection.font = .systemFont(ofSize: 20)
        noConnection.textAlignment = .center
        noConnection.textColor = .white
        noConnection.backgroundColor = .black
        noConnection.layer.borderWidth = 2
        noConnection.layer.cornerRadius = 5
        noConnection.clipsToBounds = true
        noConnection.isHidden = true
        

//        moneyTextField.becomeFirstResponder()
        sourceTextField.inputView = sourcePicker
        
        if let itemdata = itemdata{
            
            stackViewData.isHidden = true
            remarkTextView.isHidden = true
            photoOutlet.isHidden = true
            
            photoActivityIndicator.startAnimating()
            moneyTextField.text = String(itemdata.money)
            datePickerOutlet.date = itemdata.date!
            categoryOutlet.setTitle(NSLocalizedString("\(itemdata.category!)", comment: ""), for: .normal)
            sourceTextField.text = NSLocalizedString("\(itemdata.source!)", comment: "")
            classificationOutlet.text = NSLocalizedString("\(itemdata.classification!)", comment: "")
            if classificationOutlet.text == NSLocalizedString("Expense", comment: ""){
                classificationOutlet.textColor = .systemGreen
            }else{
                classificationOutlet.textColor = .red
            }
            remarkTextView.text = itemdata.remark
            if itemdata.imageStr == nil{
                photoActivityIndicator.stopAnimating()
                stackViewData.isHidden = false
                remarkTextView.isHidden = false
                photoOutlet.isHidden = false
            }else{
                
                
                    AccountingController.shared.fetchItem(id: itemdata.imageStr ?? "") { [weak self] result in
                            switch result{
                            case .success(let url):
           
                                DispatchQueue.main.async {
//                                    self.photoOutlet.kf.setImage(with: url.image, for: .normal)
                                    self?.photoOutlet.kf.setImage(with: url.image, for: .normal, completionHandler: { [weak self] _ in
                                        self?.stackViewData.isHidden = false
                                        self?.remarkTextView.isHidden = false
                                        self?.photoOutlet.isHidden = false
                                        self?.photoActivityIndicator.stopAnimating()
                                          
                                    })
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self?.stackViewData.isHidden = false
                                    self?.remarkTextView.isHidden = false
                                    self?.photoOutlet.isHidden = false
                                    self?.photoActivityIndicator.stopAnimating()
                                    self?.photoOutlet.setImage(UIImage(systemName: "photo"), for: .normal)
                                    self?.photoOutlet.tintColor = .systemCyan
                                    self?.noConnection.text = NSLocalizedString("No internet connection,Can't display photo", comment: "")
                                    self?.noConnection.isHidden = false
                                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                        self?.noConnection.isHidden = true
                                    }
                                }
                                  print(error)
                            }
                        }
                          
                        
//
//                        DispatchQueue.main.async { [weak self] in
//                            self?.stackViewData.isHidden = false
//                            self?.remarkTextView.isHidden = false
//                            self?.photoOutlet.isHidden = false
//                            self?.photoOutlet.isEnabled = false
//                            self?.photoActivityIndicator.stopAnimating()
//                            self?.photoOutlet.setImage(UIImage(systemName: "photo"), for: .normal)
//                            self?.photoOutlet.tintColor = .systemCyan
//                            self?.noConnection.text = "網路未連接，無法顯示照片"
//                            self?.noConnection.isHidden = false
//                            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
//                                self?.noConnection.isHidden = true
//                            }
//                        }
                         
                    
            }
            
//            let image = UIImage(data: itemdata.photo ?? Data())
//            photoOutlet.setImage(image, for: .normal)
        }
        
        remarkTextView.layer.borderWidth = 1
        remarkTextView.layer.cornerRadius = 10
        remarkTextView.layer.borderColor = UIColor.gray.cgColor
        remarkTextView.delegate = self
        
         
        
        placeholder.frame.size = CGSize(width: 190,height: 20)
        placeholder.text = NSLocalizedString("  Write something...", comment: "")
        placeholder.textColor = .lightGray
//        placeholder.backgroundColor = .white
        placeholder.font = UIFont.systemFont(ofSize: 17)
//        placeholder.layer.cornerRadius = 10
        remarkTextView.addSubview(placeholder)
        if remarkTextView.text.isEmpty != true{
            placeholder.isHidden = true
        }
        
        
        
        
//        if let allItem = allItem{
//            moneyTextField.text = allItem.money
//            datePickerOutlet.date = allItem.date
//            categoryOutlet.setTitle(allItem.category, for: .normal)
//            sourceTextField.text = allItem.source
//            classificationOutlet.text = allItem.classification
//            if classificationOutlet.text == "支出"{
//                classificationOutlet.textColor = .systemGreen
//            }else{
//                classificationOutlet.textColor = .red
//            }
//        }
    }
    //將得到的圖片縮小
    func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
            let size = CGSize(width: width, height:
                image.size.height * width / image.size.width)
            let renderer = UIGraphicsImageRenderer(size: size)
            let newImage = renderer.image { (context) in
                image.draw(in: renderer.format.bounds)
            }
            return newImage
    }

    
    
    @IBAction func unwindToAddView(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? CategoryCollectionViewController{
            if sourceViewController.categorySegmented.selectedSegmentIndex == 0{
                categoryOutlet.setTitle(NSLocalizedString("\(expenseCategory[sourceViewController.row].rawValue)", comment: ""), for: .normal)
                classificationOutlet.text = NSLocalizedString("Expense", comment: "")
                classificationOutlet.textColor = .systemGreen
            }else{
                categoryOutlet.setTitle(NSLocalizedString("\(incomeCategory[sourceViewController.row].rawValue)", comment: ""), for: .normal)
                classificationOutlet.text = NSLocalizedString("Income", comment: "")
                classificationOutlet.textColor = .red
            }
        }
    }
    
  
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let money = moneyTextField.text ?? ""
        let date = datePickerOutlet.date
        let category = categoryOutlet.titleLabel?.text
        let source = sourceTextField.text ?? ""
        let classification = classificationOutlet.text
        let remark = remarkTextView.text ?? ""
//        let photo = photoOutlet.image(for: .normal)?.pngData()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        if segue.identifier == "backMainView"{
            if itemdata == nil{
                let itemData = ItemData(context: appDelegate.persistentContainer.viewContext)
                itemData.money = Int32(money) ?? 0
                itemData.date = date
                itemData.category = NSLocalizedString("\(category!)", comment: "")
                itemData.source = NSLocalizedString("\(source)", comment: "")
                itemData.classification = NSLocalizedString("\(classification!)", comment: "")
                itemData.remark = remark
//                itemData.photo = photo
                itemData.imageStr = imageStr
                itemdata = itemData
//                appDelegate.saveContext()
                print("要新增")
            }else{
                itemdata?.money = Int32(money) ?? 0
                itemdata?.date = date
                itemdata?.category = NSLocalizedString("\(category!)", comment: "")
                itemdata?.source = NSLocalizedString("\(source)", comment: "")
                itemdata?.classification = NSLocalizedString("\(classification!)", comment: "")
                itemdata?.remark = remark
                if itemdata?.imageStr == nil {
                    itemdata?.imageStr = imageStr
                }
//                itemdata?.photo = photo
//                appDelegate.saveContext()
                print("要修改")
            }
        }else if segue.identifier == "backSearchView"{
            itemdata?.money = Int32(money) ?? 0
            itemdata?.date = date
            itemdata?.category = NSLocalizedString("\(category!)", comment: "")
            itemdata?.source = NSLocalizedString("\(source)", comment: "")
            itemdata?.classification = NSLocalizedString("\(classification!)", comment: "")
            itemdata?.remark = remark
            if itemdata?.imageStr == nil {
                itemdata?.imageStr = imageStr
            }
//            itemdata?.photo = photo
        }
//        allItem = AllItem(money: money, date: date, category: category!, source: source, classification: classification!)
    }

    @IBAction func okBarButton(_ sender: UIBarButtonItem) {
      
            photoActivityIndicator.startAnimating()
            okOutlet.isEnabled = false
            if moneyTextField.text?.isEmpty != true,sourceTextField.text?.isEmpty != true{
                if num == 0{
                    if itemdata?.imageStr == nil{
                        if selectPhoto == true{
                           
                            AccountingController.shared.uploadImage(uiImage: previewImage ?? UIImage(),num: 0,id: nil) { [weak self] result in
                                    switch result{
                                    case .success(let str):
                                        self?.imageStr = str
                                        DispatchQueue.main.async { [weak self] in
                                            self?.photoActivityIndicator.stopAnimating()
                                            self?.performSegue(withIdentifier: "backMainView", sender: nil)
                                        }
                                    case .failure(let error):
                                        print(error)
                                        self?.okOutlet.isEnabled = true
                                        self?.photoActivityIndicator.stopAnimating()
                                        self?.noConnection.isHidden = false
                                        self?.noConnection.text = NSLocalizedString("No internet connection\nRecording photo need internet", comment: "")
                                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
                                            self?.noConnection.isHidden = true
                                        }
                                    }
                                }
                        }else{
                            performSegue(withIdentifier: "backMainView", sender: nil)
                        }
                    }else{
                        if selectPhoto == true{
                            
                            AccountingController.shared.uploadImage(uiImage: previewImage ?? UIImage(), num: 1, id: itemdata?.imageStr) { [weak self] result in
                                switch result{
                                case .success(let str):
                                    print(str)
                                    DispatchQueue.main.async { [weak self] in
                                        self?.photoActivityIndicator.stopAnimating()
                                        self?.performSegue(withIdentifier: "backMainView", sender: nil)
                                    }
                                case .failure(let error):
                                    print(error)
                                    self?.okOutlet.isEnabled = true
                                    self?.photoActivityIndicator.stopAnimating()
                                    self?.noConnection.isHidden = false
                                    self?.noConnection.text = NSLocalizedString("No internet connection\nRecording photo need internet", comment: "")
                                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
                                        self?.noConnection.isHidden = true
                                    }
                                }
                                
                            }
                        }else{
                            self.photoActivityIndicator.stopAnimating()
                            performSegue(withIdentifier: "backMainView", sender: nil)
                        }
                    }
                }else{
                    if itemdata?.imageStr == nil{
                        if selectPhoto == true{
                           
                            AccountingController.shared.uploadImage(uiImage: previewImage ?? UIImage(),num: 0,id: nil) { [weak self] result in
                                    switch result{
                                    case .success(let str):
                                        self?.imageStr = str
                                        DispatchQueue.main.async { [weak self] in
                                            self?.photoActivityIndicator.stopAnimating()
                                            self?.performSegue(withIdentifier: "backSearchView", sender: nil)
                                        }
                                    case .failure(let error):
                                        print(error)
                                        self?.okOutlet.isEnabled = true
                                        self?.photoActivityIndicator.stopAnimating()
                                        self?.noConnection.isHidden = false
                                        self?.noConnection.text = NSLocalizedString("No internet connection\nRecording photo need internet", comment: "")
                                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
                                            self?.noConnection.isHidden = true
                                        }
                                    }
                                }
                        }else{
                            performSegue(withIdentifier: "backSearchView", sender: nil)
                        }
                    }else{
                        if selectPhoto == true{
                            AccountingController.shared.uploadImage(uiImage: previewImage ?? UIImage(), num: 1, id: itemdata?.imageStr) { [weak self] result in
                                switch result{
                                case .success(let str):
                                    print(str)
                                    DispatchQueue.main.async { [weak self] in
                                        self?.photoActivityIndicator.stopAnimating()
                                        self?.performSegue(withIdentifier: "backSearchView", sender: nil)
                                    }
                                case .failure(let error):
                                    print(error)
                                    self?.okOutlet.isEnabled = true
                                    self?.photoActivityIndicator.stopAnimating()
                                    self?.noConnection.isHidden = false
                                    self?.noConnection.text = NSLocalizedString("No internet connection\nRecording photo need internet", comment: "")
                                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
                                        self?.noConnection.isHidden = true
                                    }
                                }
                                
                            }
                        }else{
                            photoActivityIndicator.stopAnimating()
                            performSegue(withIdentifier: "backSearchView", sender: nil)
                        }
                    }
                }
            }else{
                okOutlet.isEnabled = true
                photoActivityIndicator.stopAnimating()
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please fill in Amount&Source", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                present(alert, animated: true)
            }
    }
    
  
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   
    
    // 開始編輯
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.placeholder.isHidden = true
    }
    
    // 結束編輯
    func textViewDidEndEditing(_ textView: UITextView) {
        if remarkTextView.text.isEmpty == true{
            self.placeholder.isHidden = false
        }
    }
    
    
    @IBAction func photoButton(_ sender: UIButton) {
        showSourceTypeActionSheet()
    }
    
}



extension AddModificationViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return account.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return NSLocalizedString("\(account[row].rawValue)", comment: "")
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sourceTextField.text = NSLocalizedString("\(account[row].rawValue)", comment: "")
        view.endEditing(true)
        
    }
}

extension AddModificationViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPickerViewControllerDelegate{
    
    
    func showSourceTypeActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { _ in
            print("開啟相機")
            self.showCamera()
            alert.dismiss(animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Album", comment: ""), style: .default) { _ in
            print("選擇相簿")
            self.showPhotoLibrary()
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style:.cancel) { _ in
            print("取消")
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    //UIImagePickerViewController
    func showCamera(){
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            let alert = UIAlertController(title: "提醒", message: "此裝置沒有相機", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    //UIImagePickerViewControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectImage = info[.originalImage] as? UIImage{
            //取得使用者選擇圖片
            let smallImage = resizeImage(image: selectImage, width: 374)
            previewImage = smallImage
            self.selectPhoto = true
            self.photoOutlet.setImage(smallImage, for: .normal)
            picker.dismiss(animated: true) {
            
            }
        }else{
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //PHPickerViewController
    func showPhotoLibrary(){
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    //PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first,itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        let smallImage = self.resizeImage(image: image, width: 320)
                        self.previewImage = smallImage
                        self.selectPhoto = true
                        self.photoOutlet.setImage(smallImage, for: .normal)
                        picker.dismiss(animated: true) {

                        }
                    }
                }
            }
        }else{
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
