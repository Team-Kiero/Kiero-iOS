//
//  ChildOnboardingViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/17/26.
//

import Combine
import UIKit

final class ChildOnboardingViewModel: BaseViewModel, ViewModelType {
    
    // MARK: - Input / Output
    
    struct Input {
        let nextTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let item: AnyPublisher<SpeechItem, Never>
        let fieldType: AnyPublisher<SpeechField.fieldType, Never>
        let isLast: AnyPublisher<Bool, Never>
    }
    
    // MARK: - Properties
    
    private let items: [SpeechItem]
    private let indexSubject = CurrentValueSubject<Int, Never>(0)
    private let userName: String
    
    // MARK: - Init
    
    init(items: [SpeechItem], userName: String) {
        self.items = items
        self.userName = userName
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        
        input.nextTapped
            .sink { [weak self] in
                guard let self else { return }
                guard !self.items.isEmpty else { return }
                
                let nextIndex = min(
                    self.indexSubject.value + 1,
                    self.items.count - 1
                )
                self.indexSubject.send(nextIndex)
            }
            .store(in: &cancellables)
        
        let itemPublisher = indexSubject
            .compactMap { [items] index -> SpeechItem? in
                guard items.indices.contains(index) else { return nil }
                
                let original = self.items[index]
                let name = self.userName.isEmpty ? "사용자" : self.userName
                
                let newLines = original.lines.map {
                    $0.replacingOccurrences(of: "{userName}", with: name)
                }
                
                return SpeechItem(
                    image: original.image,
                    name: original.name,
                    lines: newLines,
                    highlightKeywords: original.highlightKeywords
                )
            }
            .eraseToAnyPublisher()
        
        let fieldTypePublisher = indexSubject
            .map { [items] index -> SpeechField.fieldType in
                guard !items.isEmpty else { return .no }
                return index == items.count - 1 ? .no : .main
            }
            .eraseToAnyPublisher()
        
        let isLastPublisher = indexSubject
            .map { [items] index in
                guard !items.isEmpty else { return true }
                return index == items.count - 1
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        return Output(
            item: itemPublisher,
            fieldType: fieldTypePublisher,
            isLast: isLastPublisher
        )
    }
}
