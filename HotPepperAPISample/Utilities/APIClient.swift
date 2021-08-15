//
//  apiClient.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/08/15.
//

import Foundation

enum HotPepperAPIError: Error {
    case transportError(Error) // 通信エラー
    case serverSideError(Int) // サーバー、インフラ側でのエラー
    case decodeError
    case noData
    case noResponse
    case empty
}

extension HotPepperAPIError: CustomStringConvertible {
    var description: String {
        switch self {
        case .transportError:
            return "通信エラーが生じました\nネットワーク接続を確認してください"
        case .serverSideError (let responseStatusCode):
            switch responseStatusCode {
            case 1000:
                return "サーバー障害によるエラーが生じました"
            case 2000:
                return "API認証エラーが生じました"
            case 3000:
                return "不正なパラメータによるエラーが生じました"
            default:
                return "予期せぬサーバーエラーが生じました"
            }
        case .decodeError:
            return "デコードエラーが生じました"
        case .noData:
            return "データがありませんでした"
        case .noResponse:
            return "レスポンスがありませんでした"
        case .empty:
            return "お店が見つかりませんでした"
        }
    }
}

struct HotPepperAPIParameters {
    enum Order: Int {
        case shopName = 1
        case genre
        case area
        case recommend
    }
    
    let keyword: String
    private var _keyword: String { keyword }
    let order: Order = .recommend
    let count = 100
    let format = "json"
    let key: String = KeyManager.shared.getValue(key: "apiKeyOfHotPepper") as! String

    var queryParameters: String {
        "key=\(key)&format=\(format)&order=\(order.rawValue)&count=\(count)&keyword=\(_keyword)"
    }
}

protocol APIClientInput {
    func getShopData(parameters: HotPepperAPIParameters,
                     failure: @escaping (HotPepperAPIError) -> Void,
                     success: @escaping ((SearchResults) -> Void))
}

struct APIClient: APIClientInput {
    static let shared = APIClient()
    private init() {}
    /// APIを叩いてshopデータを取得する
    func getShopData(
        parameters: HotPepperAPIParameters,
        failure: @escaping (HotPepperAPIError) -> Void,
        success: @escaping ((SearchResults) -> Void)
    ) {
        let urlStr = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1?\(parameters.queryParameters)"
        guard
            let urlStrEncoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        let url = URL(string: urlStrEncoded)!
        let urlRequest = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // handle error
            if let error = error {
                failure(.transportError(error))
                return
            }

            guard
                let response = response as? HTTPURLResponse
            else {
                failure(.noResponse)
                return
            }
            let statusCode = response.statusCode
            guard
                case 200 ..< 300 = statusCode
            else {
                // server side error
                failure(.serverSideError(statusCode))
                return
            }

            // handle data
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard
                let data = data
            else {
                failure(.noData)
                return
            }
            do {
                let hotPepperModel = try decoder.decode(HotPepperModel.self, from: data)
                guard let results = hotPepperModel.results else { return }
                success(results)
            } catch {
                failure(.decodeError)
            }
        }
        task.resume()
    }
}

