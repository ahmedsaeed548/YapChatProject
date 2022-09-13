//
//  ServiceManager.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import Foundation
import UIKit

class ServiceManager {
    
    static func postApiCall<T: Decodable>(parameters: [String : Any], apiKey: String, completion: @escaping (Result<T,Error>) -> Void) {
    
    let post = "POST"
    let url = URL(string: "https://tlp.360scrm.com\(apiKey)")
        print("URL is \(url)")
    var request = URLRequest(url: url!)
    request.httpMethod = post
    
    request.httpBody = parameters.percentEncoded()
    
    let dataTask = URLSession.shared.dataTask(with: request) { data, response , error  in
        guard let data = data else {
            if error == nil {
                completion(.failure(error as! Error))
            }
            return
        }
        
        if let response = response as? HTTPURLResponse {
            guard (200...299) ~= response.statusCode else {
                print("Status code: \(response.statusCode)")
                print("responsse is \(response)")
                return
            }
        }
        do {
            let decoder = JSONDecoder()
            let json = try decoder.decode(T.self, from: data)
            completion(.success(json))
        } catch let error {
            print(error.localizedDescription)
        }
    }
    dataTask.resume()
}
//    func createMultipart(image: UIImage, callback: (Bool) -> Void){
//        // use SwiftyJSON to convert a dictionary to JSON
//        var parameterJSON = JSON([
//            "id_user": "test"
//        ])
//        // JSON stringify
//        let parameterString = parameterJSON.rawString(encoding: NSUTF8StringEncoding, options: nil)
//        let jsonParameterData = parameterString!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
//        // convert image to binary
//        let imageData = image.jpegData(compressionQuality: 0.7)
//        // upload is part of AlamoFire
//        upload(
//            .POST,
//            URLString: "http://httpbin.org/post",
//            multipartFormData: { multipartFormData in
//                // fileData: puts it in "files"
//                multipartFormData.appendBodyPart(fileData: jsonParameterData!, name: "goesIntoFile", fileName: "json.txt", mimeType: "application/json")
//                multipartFormData.appendBodyPart(fileData: imageData, name: "file", fileName: "iosFile.jpg", mimeType: "image/jpg")
//                // data: puts it in "form"
//                multipartFormData.appendBodyPart(data: jsonParameterData!, name: "goesIntoForm")
//            },
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .Success(let upload, _, _):
//                    upload.responseJSON { request, response, data, error in
//                        let json = JSON(data!)
//                        println("json:: \(json)")
//                        callback(true)
//                    }
//                case .Failure(let encodingError):
//                    callback(false)
//                }
//            }
//        )
//    }
//
  
}

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}


