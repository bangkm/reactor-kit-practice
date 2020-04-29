//
//  ViewController.swift
//  BasicExampleCounter
//
//  Created by Macintosh on 2020/04/29.
//  Copyright © 2020 Macintosh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

class ViewController: UIViewController, StoryboardView {
    
    let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("increase", for: .normal)
        return button
    
    }()
    
    let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("decrease", for: .normal)
        return button
    }()
    
    let valueLabel = UILabel()
    let activityIndicatorView = UIActivityIndicatorView()
    
    var disposeBag = DisposeBag()
}

// MARK:- Override Functions
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.makeAutoLayout()
    }
}

extension ViewController {
    fileprivate func makeAutoLayout() {
        self.view.addSubview(increaseButton)
        increaseButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(10)
            make.bottom.equalTo(self.view).offset(-10)
        }
        
        self.view.addSubview(decreaseButton)
        decreaseButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
        
        self.view.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self.view)
        }
        
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        }
    }
    
    internal func bind(reactor: ViewControllerReactor) {
        increaseButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map({ $0.value })
            .distinctUntilChanged()
            .map{ "\($0)" }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map{ $0.isLoading }
            .distinctUntilChanged()
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
