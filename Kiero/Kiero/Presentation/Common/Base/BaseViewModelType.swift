//
//  BaseViewModelType.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation
import Combine

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

open class BaseViewModel {
    public var cancellables = Set<AnyCancellable>()
    public let viewDidLoad = PassthroughSubject<Void, Never>()
    
    public init() {
        print("[VM Init] \(Self.self)")
    }
    
    deinit {
        print("[VM Deinit] \(Self.self)")
    }
}
