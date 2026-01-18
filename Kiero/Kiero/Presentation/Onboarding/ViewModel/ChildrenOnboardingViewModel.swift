//
//  ChildrenOnboardingViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/17/26.
//

import Combine
import UIKit

final class ChildrenOnboardingViewModel: BaseViewModel, ViewModelType {

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

    // MARK: - Init (DIContainer에서 items 주입)

    init(items: [SpeechItem]) {
        self.items = items
        super.init()
        print(items.count)
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
                return items[index]
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
