//
//  FAQViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/19.
//

import UIKit
import Toast_Swift
class FAQViewController: UIViewController {
    
    var hiddenSections = Set<Int>()
    var sectionIsSelected: [Bool] = []
    
    @IBOutlet weak var faqTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        prepareNavigationBar()
//        prepareNavigationItem()
        prepareTableView()
        print(#function)
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 네비게이션형태로바꿀시 필요한 코드
//    private func prepareNavigationBar() {
//        navigationItem.title = "FAQ"
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.backgroundColor = UIColor.clear
//        navigationController?.navigationBar.tintColor = .black
//        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: -3, right: 0))
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: -3, right: 0))
//    }
//
//    private func prepareNavigationItem() {
//        navigationController?.navigationBar.topItem?.title = ""
//
//    }
    
    private func prepareTableView() {
        let nib = UINib(nibName: QuestionHeaderView.headerIdentifier, bundle: nil)
        faqTableView.register(nib, forHeaderFooterViewReuseIdentifier: QuestionHeaderView.headerIdentifier)
        
        faqTableView.rowHeight = UITableView.automaticDimension
//        faqTableView.sectionHeaderHeight = UITableView.automaticDimension
        
        for i in 0..<Constant.faqData.count {
            self.hiddenSections.insert(i)
            self.sectionIsSelected.append(false)
        }
        self.faqTableView.delegate = self
        self.faqTableView.dataSource = self
    }
    
}

extension FAQViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constant.faqData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hiddenSections.contains(section) {
            return 0
        }
        
        return 1
    }
    
}

extension FAQViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont(name: "NotoSansKR-Regular", size: 14)
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .init(rgb: 0xf8f8f8)
        cell.textLabel?.text = Constant.faqData[indexPath.section].answer
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: QuestionHeaderView.headerIdentifier) as? QuestionHeaderView else { fatalError()}
        headerView.questionLabel.text = Constant.faqData[section].question
        headerView.sectionButton.tag = section
        
        if sectionIsSelected[section] {
            headerView.arrowImageView.image = UIImage(named: "topArrow")
        } else {
            headerView.arrowImageView.image = UIImage(named: "bottomArrow")
        }
        
        headerView.sectionButton.addTarget(self, action: #selector(self.hideSection(sender:)), for: .touchUpInside)
        
        return headerView
    }
    
    @objc private func hideSection(sender: UIButton) {
        let section = sender.tag
        
        sectionIsSelected[section] = !sectionIsSelected[section]
        
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            indexPaths.append(IndexPath(row: 0, section: section))
            
            return indexPaths
        }
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.faqTableView.insertRows(at: indexPathsForSection(), with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.faqTableView.deleteRows(at: indexPathsForSection(), with: .fade)
        }
        
        guard let header = self.faqTableView.headerView(forSection: section) as? QuestionHeaderView else { fatalError() }
        
        if sectionIsSelected[section] {
            header.arrowImageView.image = UIImage(named: "topArrow")
        } else {
            header.arrowImageView.image = UIImage(named: "bottomArrow")
        }
        
    }

}
