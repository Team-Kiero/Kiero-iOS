//
//  PickRoleViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import Combine

enum PickRoleRoute {
    case parentLogin
    case childLogin
}

final class PickRoleViewModel: BaseViewModel, ViewModelType {

    struct Input {
        let parentTapped: AnyPublisher<Void, Never>
        let childTapped: AnyPublisher<Void, Never>
    }

    struct Output {
        let route: AnyPublisher<PickRoleRoute, Never>
    }

    private let routeSubject = PassthroughSubject<PickRoleRoute, Never>()

    func transform(input: Input) -> Output {
        input.parentTapped
            .map { PickRoleRoute.parentLogin }
            .subscribe(routeSubject)
            .store(in: &cancellables)

        input.childTapped
            .map { PickRoleRoute.childLogin }
            .subscribe(routeSubject)
            .store(in: &cancellables)

        return Output(route: routeSubject.eraseToAnyPublisher())
    }
}
