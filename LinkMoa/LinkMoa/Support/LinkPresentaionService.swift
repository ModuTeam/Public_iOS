//
//  LinkPresentaionService.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/19.
//

import UIKit
import LinkPresentation
import Alamofire
import Kanna

public struct LinkPresentaionService {

    private let googleFaviconURLString: String = "https://www.google.com/s2/favicons?sz=64&domain_url="

    // 타이틀 가져오는 메서드 ( share extension 에서만 사용 )
    func fetchTitle(urlString: String, completionHandler: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandler(nil)
            return
        }
        
        let provider: LPMetadataProvider = LPMetadataProvider()
        provider.timeout = 5
        
        provider.startFetchingMetadata(for: url, completionHandler: { metadata, error in
            if let error = error {
                print(error)
                completionHandler(nil)
                return
            }
            
            completionHandler(metadata?.title)
        })
    }
    
    // completionHandler: (타이틀, 웹 이미지 URL, 파비콘 URL)
    func fetchMetaDataURL(targetURLString URLString: String, completionHandler: @escaping (WebMetaData?) -> Void) {
        guard let url = URL(string: URLString) else { return }
        
        var title: String?
        var image: String?
        let favicon = googleFaviconURLString + URLString
        
        AF.request(url).responseString(completionHandler: { response in
            switch response.result {
            case .success(let htmlString):
                do {
                    let doc = try HTML(html: htmlString, encoding: .utf8)

                    for link in doc.xpath("//meta[@property='og:title']") {
                        if let contentTitle = link["content"] {
                            title = contentTitle
                            break
                        }
                    }
                    
                    for link in doc.xpath("//meta[@property='og:image']") {
                        if let imageURLString = link["content"] {
                            image = imageURLString
                            break
                        }
                    }
                    
                    completionHandler(WebMetaData(title: title, webPreviewURLString: image, faviconURLString: favicon))
                } catch let error {
                    print(error)
                    completionHandler(WebMetaData(title: nil, webPreviewURLString: nil, faviconURLString: nil))
                }

            case .failure(let error):
                print(error)
                completionHandler(WebMetaData(title: nil, webPreviewURLString: nil, faviconURLString: nil))
            }
        })
    }
}
