//
//  ImageUpload.swift
//  YapChatProject
//
//  Created by Ahmad on 13/09/2022.
//

import Foundation
import Alamofire
import UIKit

class DocumentUpload {
    
    static func ImageUpload(_ image: UIImage, url: String) {
        guard image.jpegData(compressionQuality: 0.9) != nil else {
                return
            }
            let imagedata = image.jpegData(compressionQuality: 0.3)
            Alamofire.upload(multipartFormData: { MultipartFormData in
               
                MultipartFormData.append(imagedata!, withName: "files" , fileName: "image.jpg" , mimeType: "image/jpg")
            },to: "\(url)", encodingCompletion: {
                EncodingResult in
                switch EncodingResult{
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        guard let json = response.result.value! as? [String: Any] else {
                            return
                        }
                        print(json)
                    }
                case .failure(let encodingError):
                    print("ERROR RESPONSE: \(encodingError)")
                }
            })
        }
    
    static func audioUpload(path: URL, url: String, fileName: String) {
            Alamofire.upload(multipartFormData: { MultipartFormData in
               
                MultipartFormData.append(path, withName: "files" , fileName: fileName , mimeType: "\(fileName)/wav")
            },to: "\(url)", encodingCompletion: {
                EncodingResult in
                switch EncodingResult{
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        guard let json = response.result.value! as? [String: Any] else {
                            return
                        }
                        print(json)
                    }
                case .failure(let encodingError):
                    print("ERROR RESPONSE: \(encodingError)")
                }
            })
        }
}
