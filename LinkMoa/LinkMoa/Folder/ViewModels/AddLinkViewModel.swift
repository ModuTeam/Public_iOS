//
//  AddLinkViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/10.
//

import Foundation

protocol AddLinkViewModelOutputs {}

protocol AddLinkViewModelInputs {
    func addLink(folder index: Int, params: [String: Any], completionHandler: @escaping (Result<LinkResponse, Error>) -> Void)
    func editLink(link index: Int, params: [String: Any], completionHandler: @escaping (Result<LinkResponse, Error>) -> Void)
    func deleteLink(link index: Int, completionHandler: @escaping (Result<LinkResponse, Error>) -> Void)
}

protocol AddLinkViewModelType {
    var inputs: AddLinkViewModelInputs { get }
    var outputs: AddLinkViewModelOutputs { get }
}

final class AddLinkViewModel: AddLinkViewModelOutputs, AddLinkViewModelInputs, AddLinkViewModelType {

    private let myScallopManager = MyScallopManager()

    var inputs: AddLinkViewModelInputs { return self }
    var outputs: AddLinkViewModelOutputs { return self }

    func addLink(folder index: Int, params: [String: Any], completionHandler: @escaping (Result<LinkResponse, Error>) -> Void) {
        myScallopManager.addLink(folder: index, params: params, completion: completionHandler)
    }
    
    func editLink(link index: Int, params: [String: Any], completionHandler: @escaping (Result<LinkResponse, Error>) -> Void) {
        myScallopManager.editLink(link: index, params: params, completion: completionHandler)
    }
    
    func deleteLink(link index: Int, completionHandler: @escaping (Result<LinkResponse, Error>) -> Void) {
        myScallopManager.deleteLInk(link: index, completion: completionHandler)
    }
}
