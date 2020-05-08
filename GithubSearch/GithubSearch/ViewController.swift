//
//  ViewController.swift
//  GithubSearch
//
//  Created by Macintosh on 2020/05/06.
//  Copyright © 2020 Macintosh. All rights reserved.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import RxSwift
import SafariServices

class ViewController: UIViewController, View {
    // let searchController = UISearchController(searchResultsController: nil)
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        return searchController
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var disposeBag = DisposeBag()
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.verticalScrollIndicatorInsets.top = tableView.contentInset.top
        makeComponents()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(false)
        searchController.isActive = true
        searchController.isActive = false
        UIView.setAnimationsEnabled(false)
    }
}

extension ViewController {
    fileprivate func makeComponents() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(view)
        }
    }
    
    fileprivate func setupSearchController() {
        navigationItem.searchController = searchController
    }
    
    func bind(reactor: ViewControllerReactor) {
        searchController.searchBar.rx.text
            .throttle(.microseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter{ [weak self] offset in
                guard let self = self else { return false }
                guard self.tableView.frame.height > 0 else { return false }
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
            }
            .map{ _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{ $0.repos }
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { indexPath, repo, cell in
                cell.textLabel?.text = repo
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self, weak reactor] indexPath in
                guard let self = self else { return }
                self.view.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: false)
                guard let repo = reactor?.currentState.repos[indexPath.row] else { return }
                guard let url = URL(string: "https://github.com/\(repo)") else { return }
                let viewController = SFSafariViewController(url: url)
                self.searchController.present(viewController, animated: true, completion: nil)
            })
        .disposed(by: disposeBag)
            
    }
}

