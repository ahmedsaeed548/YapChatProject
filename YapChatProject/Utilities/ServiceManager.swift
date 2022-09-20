//
//  ServiceManager.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import Foundation
import UIKit

enum StatusResponse: String {
    case success = "The request has been successfull"
    case badRequest = ""
}

class ServiceManager {
    
    static func postApiCall<T: Decodable>(parameters: [String : Any], apiKey: String, completion: @escaping (Result<T,Error>) -> Void) {
    
    let post = "POST"
    let url = URL(string: "https://tlp.360scrm.com\(apiKey)")
        print("URL is \(url!)")
    var request = URLRequest(url: url!)
    request.httpMethod = post
    
    request.httpBody = parameters.percentEncoded()
    
    let dataTask = URLSession.shared.dataTask(with: request) { data, response , error  in
        guard let data = data else {
            if error == nil {
                completion(.failure(error!))
            }
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.status ?? "")
        }
        do {
            let decoder = JSONDecoder()
            let json = try decoder.decode(T.self, from: data)
            completion(.success(json))
            print("Json is: \(json)")
        } catch let error {
            print(error.localizedDescription)
        }
    }
    dataTask.resume()
}
  
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


