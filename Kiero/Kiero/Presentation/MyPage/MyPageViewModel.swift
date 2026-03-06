//
//  MyPageViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import Combine
import SwiftUI

final class MyPageViewModel: ObservableObject {
    
    @Published var userName: String = "꾸비"
    @Published var userImage: String? = nil
    @Published var connectedChild: Int = 0
    
    let scrollToTop = PassthroughSubject<Void, Never>()
    
}
