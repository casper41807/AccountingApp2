//
//  AirTableResponse.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/14.
//

import Foundation
import Alamofire
import UIKit


class AccountingController{
    static let shared = AccountingController()
    private let baseURL = URL(string: "https://api.airtable.com/v0/appjAvWZDqTgRklgL/Accounting")!
    
    //Get
    func fetchItem(id:String,completion:@escaping (Result<Fetch.Fields,Error>)->()){
        let urlStr = "https://api.airtable.com/v0/appjAvWZDqTgRklgL/Accounting/\(id)"
        if let url = URL(string: urlStr){
            var request = URLRequest(url: url)
//            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                let decoder = JSONDecoder()
                if let data = data {
                    do{
                        let image = try decoder.decode(Fetch.self, from: data)
                        completion(.success(image.fields))
                    }catch{
                        print("解碼失敗")
                        completion(.failure(error))
                    }
                }else if let error = error {
                    print("下載失敗")
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    //Delete
    func deleteItem(id:String){
        let urlStr = "https://api.airtable.com/v0/appjAvWZDqTgRklgL/Accounting/\(id)"
        if let url = URL(string: urlStr){
            var request = URLRequest(url: url)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error == nil{
                    print("刪除圖片網址成功")
                }else{
                    print(error ?? "失敗")
                }
            }.resume()
        }
    }
    //Patch
    func patchItem(data:Accounting){
        
            var request = URLRequest(url: baseURL)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PATCH"
            let encoder = JSONEncoder()
            request.httpBody = try?encoder.encode(data)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error == nil{
                    print("更改網址成功")
                }else{
                    print(error ?? "失敗")
                }
            }.resume()
    }

    //Post
    func postItem(data:Accounting,completion:@escaping (Result<String,Error>)->()){
        
            var request = URLRequest(url: baseURL)
            request.setValue("Bearer keyGnfMCwVt6ZxYfS", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "Post"
            let encoder = JSONEncoder()

            request.httpBody = try?encoder.encode(data)
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if let data = data {
                    let decoder = JSONDecoder()
                    do{
                        let str = try decoder.decode(Accounting.self, from: data)
                        completion(.success(str.records.first?.id ?? ""))
                    }catch{
                        print("解碼失敗")
                        completion(.failure(error))
                    }
                }else if let error = error{
                    completion(.failure(error))
                }
            }.resume()
    }
    
    func uploadImage(uiImage: UIImage,num:Int,id:String?,completion:@escaping (Result<String,Error>)->()){
            let headers: HTTPHeaders = [
                "Authorization": "Client-ID 3e943d291f594f7",
            ]
            AF.upload(multipartFormData: { data in
                if let imageData = uiImage.jpegData(compressionQuality: 0.9){
                    data.append(imageData, withName: "image")
                }

            }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: ImgurImageResponse.self, queue: .main, decoder: JSONDecoder()) { [self] response in
                switch response.result {
                case .success(let result):
                    if num == 0{
                        let post = Accounting(records: [.init(id: id, fields: .init( image: result.data.link))])
                        
                        self.postItem(data: post) { result in
                            switch result{
                            case .success(let result) :
                               print(result)
                                completion(.success(result))
                            case .failure(let error):
                                print(error)
                                completion(.failure(error))
                            }
                        }
                    }else{
                        let post = Accounting(records: [.init(id: id, fields: .init(image: result.data.link))])
                        self.patchItem(data: post)
                        completion(.success("修改成功"))
                    }
                    
                    print(result.data.link)
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
            }
    }
}
    

 



    struct Accounting:Codable{
        
        let records:[Records]
        struct Records:Codable{
            
            let id:String?
            let fields:Fields
            
            struct Fields:Codable{
                let image:URL
            }
        }
    }


    struct Fetch:Codable{
        let fields:Fields
        
        struct Fields:Codable{
            let image:URL
        }
    }


 





    struct ImgurImageResponse:Codable{
        let data:Data
        struct Data:Codable{
            let link:URL
        }
    }


