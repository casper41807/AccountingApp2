//
//  CategoryCollectionViewController.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/29.
//

import UIKit

//private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController {

    @IBOutlet weak var categorySegmented: UISegmentedControl!
    
    var row = 0
    let expenseCategory = ExpenseCategory.allCases
    let incomeCategory = IncomeCategory.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCellSize()
        overrideUserInterfaceStyle = .light
        
       

    }
    
    @IBAction func Category(_ sender: UISegmentedControl) {
        collectionView.reloadData()
    }
    
    
    func configureCellSize() {
            //間距距離
            let itemSpace: Double = 5
            //3張照片
            let columnCount: Double = 3
            let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
            //寬度會是 collectionView寬度 - ((間隔*幾張圖片-1)/幾張圖片)
        let width = floor((collectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
            flowLayout?.itemSize = CGSize(width: width, height: width)
            //將 estimatedItemSize 設為 .zero，如此 cell 的尺寸才會依據 itemSize，否則它將從 auto layout 的條件計算 cell 的尺寸
            flowLayout?.estimatedItemSize = .zero
            flowLayout?.minimumInteritemSpacing = itemSpace
            flowLayout?.minimumLineSpacing = itemSpace
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        row = collectionView.indexPathsForSelectedItems?.first?.row ?? 0
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if categorySegmented.selectedSegmentIndex == 0{
            return expenseCategory.count
        }else{
            return incomeCategory.count
        }
        
        

        
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else {return UICollectionViewCell()}
        
        if categorySegmented.selectedSegmentIndex == 0{
            let expenseIndex = expenseCategory[indexPath.item]
            cell.categoryImage.image = UIImage(named:expenseIndex.rawValue)
            cell.categoryLabel.text = NSLocalizedString("\(expenseIndex.rawValue)", comment: "")
        }else{
            let incomeIndex = incomeCategory[indexPath.item]
            cell.categoryImage.image = UIImage(named:incomeIndex.rawValue)
            cell.categoryLabel.text = NSLocalizedString("\(incomeIndex.rawValue)", comment: "")
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        navigationController?.popViewController(animated: true)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
