//
//  DiaryEditViewController.swift
//  Diary
//
//  Created by Christy, vetto on 2023/04/25.
//

import UIKit

final class DiaryEditViewController: UIViewController {
    private let diaryData: DiaryData?
    private var diaryType: DiaryType
    
    private let textView: UITextView = {
        let textView = UITextView()
        
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.keyboardDismissMode = .onDrag
        configureText()
        configureUI()
        configureTitle()
        showKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let (title, body) = divide(text: textView.text)
        guard let title,
              let body else { return }
        
        switch diaryType {
        case .new:
            CoreDataManger.shared.createDiary(title: title, body: body)
            self.diaryType = .old
        case .old:
            guard let date = diaryData?.createDate,
                  let id = diaryData?.id else { return }
            CoreDataManger.shared.updateDiary(id: id,
                                              title: title,
                                              createDate: date,
                                              body: body)
        }
    }
    
    init(diaryData: DiaryData? = nil, type: DiaryType = .new) {
        self.diaryData = diaryData
        self.diaryType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        
        let image = UIImage(systemName: "ellipsis.circle")
        let navigationRightButton = UIBarButtonItem(image: image,
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(ellipsisButtonTapped))
        
        self.navigationItem.rightBarButtonItem = navigationRightButton
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    @objc private func ellipsisButtonTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "공유", style: .default) { _ in
            self.presentShareSheet()
        }
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        actionSheet.addAction(shareAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true)
    }
    
    func presentShareSheet() {
        let shareText: String = "share text test!"
        var shareObject = [Any]()
        
        shareObject.append(shareText)
        
        let activityViewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [.postToFacebook]

        self.present(activityViewController, animated: true)
    }
    
    private func configureText() {
        guard let title = diaryData?.title,
              let body = diaryData?.body else { return }
        textView.text = "\(title)\n\(body)"
    }
    
    private func configureTitle() {
        guard let date = diaryData?.createDate else { return }
        navigationItem.title = DateManger.shared.convertToDate(fromDouble: date)
    }
    
    private func divide(text: String?) -> (title: String?, body: String?) {
        guard let text,
              let spacingIndex = text.firstIndex(of: "\n") else {
            return ("", nil)
        }
        let spacingNextIndex = text.index(after: spacingIndex)
        let title = String(text[..<spacingIndex])
        let body = String(text[spacingNextIndex...])
        
        return (title, body)
    }
    
    private func showKeyboard() {
        if diaryType == .new {
            textView.becomeFirstResponder()
        }
    }
}
