//
//  ArticleDetailViewController.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//

import UIKit
import WebKit

class ArticleDetailViewController: UIViewController {
    
    private let article: Article
    private let webView = WKWebView()
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadArticle()
    }
    
    private func setupWebView() {
        title = article.title
        view.backgroundColor = .systemBackground
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadArticle() {
        guard let url = URL(string: article.url) else {
            let alert = UIAlertController(title: "Error", message: "Invalid article URL.", preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] _ in
				guard let self else { return }
				self.navigationController?.popViewController(animated: true)
			}))
            present(alert, animated: true)
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
