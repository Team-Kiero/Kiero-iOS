//
//  ParentOnboardingViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

final class ParentOnboardingViewModel: BaseViewModel {
    let name: String
    let profileURL: String
    
    init(name: String, profileURL: String) {
        self.name = name
        self.profileURL = profileURL
        super.init()
    }
}
