//
//  ShowDetailViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/5.
//

import UIKit
import Kingfisher

class ShowDetailViewController: UIViewController {

    @IBOutlet weak var moneyTextField: UITextField!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var sourceTextField: UITextField!
    
    @IBOutlet weak var classificationLabel: UILabel!

    @IBOutlet weak var remarkTextView: UITextView!
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var photoActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var showPhotoOutlet: UIButton!
    
    @IBOutlet weak var stackViewData: UIStackView!
    
    var itemdata:ItemData?
    var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPhotoOutlet.isHidden = true
        
        photoActivity.startAnimating()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日 a h:mm"
        
        if let itemdata = itemdata{
            
            stackViewData.isHidden = true
            remarkTextView.isHidden = true
            
            moneyTextField.text = String(itemdata.money)
            if dateFormatter.string(from: itemdata.date!).contains("AM"){
                dateFormatter.dateFormat = "yyyy年M月d日 上午h:mm"
            }else{
                dateFormatter.dateFormat = "yyyy年M月d日 下午h:mm"
            }
            dateLabel.text = dateFormatter.string(from: itemdata.date!)
            categoryButton.setTitle(itemdata.category!, for: .normal)
            sourceTextField.text = itemdata.source
            classificationLabel.text = itemdata.classification
            if classificationLabel.text == "支出"{
                classificationLabel.textColor = .systemGreen
            }else{
                classificationLabel.textColor = .red
            }
            
            remarkTextView.layer.borderWidth = 1
            remarkTextView.layer.cornerRadius = 10
            remarkTextView.layer.borderColor = UIColor.gray.cgColor
            
            if itemdata.remark == ""{
                remarkTextView.text = "無備註"
            }else{
                remarkTextView.text = itemdata.remark
            }
            if itemdata.imageStr == nil{
                photoActivity.stopAnimating()
                self.stackViewData.isHidden = false
                self.remarkTextView.isHidden = false
            }else{
                AccountingController.shared.fetchItem(id: itemdata.imageStr ?? "") { [weak self] result in
                    switch result{
                    case .success(let url):
  
                        self?.url = url.image
                        DispatchQueue.main.async {
                            
                            self?.photoImage.kf.setImage(with: url.image, completionHandler: { [weak self] _ in
                                self?.stackViewData.isHidden = false
                                self?.remarkTextView.isHidden = false
                                self?.photoActivity.stopAnimating()
                                self?.showPhotoOutlet.isHidden = false
                            })
                        
                        }
                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async {
                        self?.photoActivity.stopAnimating()
                        self?.stackViewData.isHidden = false
                        self?.remarkTextView.isHidden = false
                        self?.photoImage.image = UIImage(systemName: "photo")
                        
                        }
                    }
                }
            }
            
            
            
        }
        overrideUserInterfaceStyle = .light
    }
    
    @IBSegueAction func showPhoto(_ coder: NSCoder) -> PhotoViewController? {
        let controller = PhotoViewController(coder: coder)
        controller?.url = url
        return controller
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
