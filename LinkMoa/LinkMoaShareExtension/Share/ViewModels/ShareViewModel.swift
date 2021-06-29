//
//  ShareViewModel.swift
//  LinkMoaShareExtension
//
//  Created by won heo on 2021/02/26.
//

import Foundation

protocol ShareViewModelOutputs {}
protocol ShareViewModelInputs {
    func addLink(folder index: Int, params: [String: Any], completionHandler: @escaping (Result<LinkResponse, Error>) -> Void)
}

protocol ShareViewModelType {
    var inputs: ShareViewModelInputs { get }
    var outputs: ShareViewModelOutputs { get }
}

final class ShareViewModel: ShareViewModelOutputs, ShareViewModelInputs, ShareViewModelType {
    
    private let myScallopManager = MyScallopManager()

    var inputs: ShareViewModelInputs { return self }
    var outputs: ShareViewModelOutputs { return self }
    
    func addLink(folder index: Int, params: [String: Any], completionHandler: @escaping (Result<LinkResponse, Error>) -> Void) {
        myScallopManager.addLink(folder: index, params: params, completion: completionHandler)
    }
}
