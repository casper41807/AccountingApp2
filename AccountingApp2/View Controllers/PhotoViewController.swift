//
//  PhotoViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/16.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImage.kf.setImage(with: url)
        // Do any additional setup after loading the view.
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
