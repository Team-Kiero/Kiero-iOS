//
//  BaseViewController.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit
import Combine

open class BaseViewController<VM: BaseViewModel>: UIViewController {
    
    // MARK: - Properties
    
    public var cancellables = Set<AnyCancellable>()
    public var viewModel: VM?
    public let diContainer: any ViewControllerFactory
    
    // MARK: - Init
    
    public init(viewModel: VM, diContainer: any ViewControllerFactory) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
        bind(viewModel: viewModel)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    open override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kBlack
        
        setStyle()
        setUI()
        setLayout()
        addTarget()
        setDelegate()
        bindViewModel()
    }
    
    // MARK: - Custom Method
    
    open func setStyle() {}
    open func setUI() {}
    open func setLayout() {}
    open func addTarget() {}
    open func setDelegate() {}
    open func bindViewModel() { }
    
    // MARK: - Bind Method
    
    open func bind(viewModel: VM) {
        self.viewModel = viewModel
    }
    
    deinit {
        print("[VC Deinit] \(Self.self)")
    }
}
