//
//  SelectViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/15.
//

import Foundation
import RxCocoa
import RxSwift

class SelectViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource{
    // MARK:業務設定
    private let onSelectedClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    var codeArray:[String] = []
    var nameArray:[String] = []
    var searchArray: [String] = [String]()
    var codeDic:Dictionary<String , Array<String>> = [:]
    var nameDic:Dictionary<String , Array<String>> = [:]
    var sortedCodeDataArray : Array<(key: String, value: Array<String>)> = []
    var sortedNameDataArray : Array<(key: String, value: Array<String>)> = []
    // 用此變數表示現在是否為搜尋模式
    var searching = false
    var allCountriesData : [CountryDetail] = []
    var codeNameData : CountryDetail = CountryDetail()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topCodeLabel: UILabel!
    @IBOutlet weak var topNameLabel: UILabel!
    @IBOutlet weak var dismissImageView: UIImageView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindImageView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
        secondSetupUI()
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
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = UIColor(rgb: 0x707EAE)
//        tableView.sectionIndexBackgroundColor = .red
        searchBar.delegate = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    func setupData()
    {
        let countriesData = allCountriesData
        codeArray = countriesData.map({
            return $0.code
        })
        nameArray = countriesData.map({
            return $0.name
        })
        createArray(withData: countriesData)
    }
    func secondSetupUI()
    {
        topCodeLabel.text = codeNameData.code
        topNameLabel.text = codeNameData.name
    }
 
    func createArray(withData countriesData: [CountryDetail])
    {
        let prepareCodeArray = countriesData.map({
            return $0.code
        })
        let prepareNameArray = countriesData.map({
            return $0.name
        })
        
        let indexArray = prepareNameArray.map({
            return String($0.prefix(1))
        })
        var indexSet:Set<String> = []
        codeDic.removeAll()
        nameDic.removeAll()
        for nameString in indexArray
        {
            indexSet.insert(nameString)
            nameDic[nameString] = []
            codeDic[nameString] = []
        }

        for indexString in indexSet {
            for nameString in prepareNameArray {
                if String(nameString.prefix(1)) == indexString
                {
                    nameDic[indexString]?.append(nameString)
                    guard let integer = prepareNameArray.firstIndex(of: nameString) else { return }
                    codeDic[indexString]?.append(prepareCodeArray[integer])
                }
            }
        }
        sortedCodeDataArray = codeDic.sorted(by: { $0.key < $1.key } )
        sortedNameDataArray = nameDic.sorted(by: { $0.key < $1.key } )
    }
    func rxSelectedClick() -> Observable<String>
    {
        return onSelectedClick.asObservable()
    }
    func bindImageView()
    {
        dismissImageView.rx.click.subscribeSuccess { _ in
            self.dismiss(animated: true)
        }.disposed(by: dpg)
    }
}

// MARK: -
// MARK: 延伸
extension SelectViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let countriesData = allCountriesData
        if searchText.count != 0
        {
            let newData = countriesData.filter ({ detailDto -> Bool in
                var isCodeMach = false
                var isNameMach = false
                isCodeMach = detailDto.code.localizedCaseInsensitiveContains(searchText)
                isNameMach = detailDto.name.localizedCaseInsensitiveContains(searchText)
                return isCodeMach || isNameMach
            })
            createArray(withData: newData)
        }else
        {
            createArray(withData: countriesData)
        }
        searching = searchText.count == 0 ? false : true
        tableView.reloadData()
    }
    
}
extension SelectViewController {
    // 索引设置
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var indexArray:[String] = []
        for (key , _) in sortedNameDataArray {
            indexArray.append(key)
        }
        return indexArray
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        print(title , index)
        tableView.scrollToRow(at: IndexPath(item: 0, section: index), at: .top, animated: true)
        return index
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedNameDataArray.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Views.screenWidth, height: 18))
        headerView.backgroundColor = UIColor(rgb: 0xEFF4FB)
        let headerLabel = UILabel()
        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        headerLabel.textColor = UIColor(rgb: 0xA3AED0)
        headerLabel.text = sortedNameDataArray[section].key
        headerLabel.font = Fonts.SFProDisplayBold(13)
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCode = sortedCodeDataArray[indexPath.section].value[indexPath.row]
        onSelectedClick.onNext(selectedCode)
        self.dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedNameDataArray[section].value.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueCell(type: SearchAreaTableViewCell.self, indexPath: indexPath)
        cell.codeLabel.text = sortedCodeDataArray[indexPath.section].value[indexPath.row]
        cell.nameLabel.text = sortedNameDataArray[indexPath.section].value[indexPath.row]
        if sortedCodeDataArray[indexPath.section].value.count == (indexPath.row + 1)
        {
            cell.separatorLineView.isHidden = true
        }else
        {
            cell.separatorLineView.isHidden = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
}
