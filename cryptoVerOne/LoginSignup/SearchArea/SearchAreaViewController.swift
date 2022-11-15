//
//  SearchAreaViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/15.
//

import Foundation
import RxCocoa
import RxSwift

class SearchAreaViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource{
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var codeArray:[String] = []
    var nameArray:[String] = []
    var searchArray: [String] = [String]()
    var nameDic:Dictionary<String , Array<String>> = [:]
    // 用此變數表示現在是否為搜尋模式
    var searching = false
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func setupViews()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerXibCell(type: SearchAreaTableViewCell.self)
        tableView.separatorStyle = .singleLine
        searchBar.delegate = self
    }
    func setupData()
    {
        guard let path = Bundle.main.path(forResource: "countries", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let results = try decoder.decode(CountriesDto.self, from:data)
            
            codeArray = results.countries.map({
                return $0.code
            })
            nameArray = results.countries.map({
                return $0.name
            })
            
            let indexArray = nameArray.map({
                return String($0.prefix(1))
            })
            var indexSet:Set<String> = []
            for nameString in indexArray
            {
                indexSet.insert(nameString)
                nameDic[nameString] = []
            }
            for indexString in indexSet {
                for nameString in nameArray {
                    if String(nameString.prefix(1)) == indexString
                    {
                        nameDic[indexString]?.append(nameString)
                    }
                }
            }
            
//            nameDic = nameDic.sorted { $0.key.0 < $1.key.0 }
            Log.i("results: \(nameDic)")
        } catch {
            print(error)
        }
    }
}
// MARK: -
// MARK: 延伸
extension SearchAreaViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchArray = citiArray.filter({ (string) -> Bool in
//            return  string.prefix(searchText.count) == searchText
//        })
//        searching = true
        searchArray = nameArray.filter({ (string) -> Bool in
            let words = string
            let isMach = words.localizedCaseInsensitiveContains(searchText)
            return isMach
        })
        searching = searchText.count == 0 ? false : true
        tableView.reloadData()
    }
    
}
extension SearchAreaViewController {
    // 索引设置
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var indexArray:[String] = []
        if searching {
            indexArray = searchArray.map({
                return String($0.prefix(1))
            })
        }else
        {
            indexArray = nameArray.map({
                return String($0.prefix(1))
            })
        }
        return indexArray
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        print(title , index)
        tableView.scrollToRow(at: IndexPath(item: index, section: 0), at: .top, animated: true)
        return index
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if searching {
                return searchArray.count
            } else {
                return nameArray.count
            }
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueCell(type: SearchAreaTableViewCell.self, indexPath: indexPath)
        if searching {
            cell.nameLabel.text = searchArray[indexPath.row]
        } else {
            cell.nameLabel.text = nameArray[indexPath.row]
        }
        
        
        
        return cell
    }
}
