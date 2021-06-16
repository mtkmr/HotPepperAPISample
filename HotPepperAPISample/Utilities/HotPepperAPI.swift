//
//  API.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import Foundation

enum HotPepperAPIError: Error {
    case server(Int)
    case invalidQuery
    case noResponse
    case decode
    case unknown(Error)
    
    var description: String {
        switch self {
        case .server(let statusCode):
            return "サーバーエラー ステータスコード: \(statusCode)"
        case .invalidQuery:
            return "不正なqueryが渡されました"
        case .noResponse:
            return "レスポンスを取得できませんでした"
        case .decode:
            return "デコードエラーです"
        case .unknown(let error):
            return "エラーが発生しました \(error.localizedDescription)"
        }
    }
}

let keyManager = KeyManager()

struct HotPepperAPIParameters {
    enum Order: Int {
        case shopName = 1
        case genre
        case area
        case recommend
    }
    
    enum Range: Int {
        case threeHundred = 300
        case fiveHundred = 500
        case oneThousand = 1000
        case twoThousand = 2000
        case threeThousand = 3000
    }
    
    let latitude: Double?
    private var _latitude: Double {
        latitude ?? 0.0
    }
    let longitude: Double?
    private var _longitude: Double {
        longitude ?? 0.0
    }
    let range: Range = .oneThousand
    let order: Order = .recommend
    let count = 10
    let format: String = "json"
    let key: String = keyManager.getValue(key: "apiKeyOfHotPepper") as! String
    
    var validation: Bool {
        count >= 1 && count <= 100
    }
    
    var queryParameters: String {
        "key=\(key)&format=\(format)&order=\(order.rawValue)&count=\(count)&lat=\(_latitude)&lng=\(_longitude)&range=\(range.rawValue)"
    }
}

protocol HotPepperAPIProtocol: AnyObject {
    func get(parameters: HotPepperAPIParameters,
             completion: ((Result<Results, HotPepperAPIError>) -> Void)?)
}

//HotPepperAPI用のインターフェースを作成
final class HotPepperAPI: HotPepperAPIProtocol {
    static let shared = HotPepperAPI()
    private init() {}
    
    func get(parameters: HotPepperAPIParameters,
             completion: ((Result<Results, HotPepperAPIError>) -> Void)?) {
        guard parameters.validation else {
            completion?(.failure(.invalidQuery))
            return
        }
        let urlStr = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1?\(parameters.queryParameters)"
        guard let urlStrEncoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let url = URL(string: urlStrEncoded)!
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion?(.failure(.unknown(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse
            else {
                completion?(.failure(.noResponse))
                return
            }
            
            if case 200 ..< 300 = response.statusCode {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                //処理成功
                guard
                    let data = data,
                    let hotPepperModel = try? decoder.decode(HotPepperModel.self, from: data),
                    let results = hotPepperModel.results
                else {
                    completion?(.failure(.decode))
                    return
                }
                
                completion?(.success(results))
                
            } else {
                //処理失敗
                completion?(.failure(.server(response.statusCode)))
            }
        }
        task.resume()
    }
   
}
