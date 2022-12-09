//
//  SelectViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/15.
//

import Foundation
import RxCocoa
import RxSwift

enum SelectViewMode :Equatable{
    case selectArea(String)
    case selectCrypto
    
    var phoneCode:String?{
        switch self {
        case .selectArea(let phonecode):
            return phonecode
        default:
            return ""
        }
    }
}
class SelectViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource{
    // MARK:業務設定
    private let onSelectedAreaCodeClick = PublishSubject<String>()
    private let onSelectedCryptoClick = PublishSubject<SelectCryptoDetailDto>()
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
    // Crypto模式下的資料
    var allCryptosData : [SelectCryptoDetailDto] = []
    var sortedCryptosDataArray : [SelectCryptoDetailDto]  = []
    
    var currentSelectMode:SelectViewMode = .selectArea("")
    {
        didSet{
           createDataByMode(mode: currentSelectMode)
        }
    }
    @IBOutlet weak var currentCodeViewHeight: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentCodeView: UIView!
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
        tableView.registerXibCell(type: SelectCryptoCell.self)
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = UIColor(rgb: 0x707EAE)
        searchBar.backgroundColor = Themes.grayF4F7FE
        searchBar.barTintColor = Themes.grayF4F7FE
//        searchBar.backgroundImage = UIImage()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    func setupCryptosData()
    {
        createCryptoArray(withData: allCryptosData)
    }
    func setupCountriesData()
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
    func setupCountriesUI()
    {
        topCodeLabel.text = codeNameData.code
        topNameLabel.text = codeNameData.name
    }
    func createCryptoArray(withData cryptosDto: [SelectCryptoDetailDto])
    {
        Log.i("目前沒有做特殊處理")
        sortedCryptosDataArray = cryptosDto
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
    func rxSelectedAreaCodeClick() -> Observable<String>
    {
        return onSelectedAreaCodeClick.asObservable()
    }
    func rxSelectedCryptoClick() -> Observable<SelectCryptoDetailDto>
    {
        return onSelectedCryptoClick.asObservable()
    }
    func bindImageView()
    {
        dismissImageView.rx.click.subscribeSuccess { _ in
            self.dismiss(animated: true)
        }.disposed(by: dpg)
    }
    func getCryptosData() -> [SelectCryptoDetailDto]
    {
        let usdt = SelectCryptoDetailDto(cryptoName: "USDT", cryptoIconName: "icon-usdt", cryptoNetworkName: "Tether")
        let usdc = SelectCryptoDetailDto(cryptoName: "USDC", cryptoIconName: "icon-usdc", cryptoNetworkName: "USD Coin")
        let cryptosDto = SelectCryptoDto(cryptos: [usdt,usdc])
        return cryptosDto.cryptos
    }

    func createDataByMode(mode:SelectViewMode)
    {
        if mode == .selectCrypto
        {
            self.allCryptosData = getCryptosData()
            titleLabel.text = "Select Crypto"
            currentCodeView.isHidden = true
            currentCodeViewHeight.constant = 0.0
            tableView.backgroundColor = Themes.grayF4F7FE
            tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            setupCryptosData()
        }else
        {
            self.allCountriesData = KeychainManager.share.getDefaultData()
            if let currentData = self.allCountriesData.filter({ $0.code == currentSelectMode.phoneCode }).first
            {
                self.codeNameData = currentData
            }
            titleLabel.text = "Select Area Code"
            currentCodeView.isHidden = false
            currentCodeViewHeight.constant = 46.0
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            setupCountriesData()
            setupCountriesUI()
        }
    }
}

// MARK: -
// MARK: 延伸
extension SelectViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if currentSelectMode == .selectCrypto
        {
            let cryptosData = allCryptosData
            if searchText.count != 0
            {
                let newData = cryptosData.filter ({ detailDto -> Bool in
                    var isNameMach = false
                    var isNetworkMach = false
                    isNameMach = detailDto.cryptoName.localizedCaseInsensitiveContains(searchText)
                    isNetworkMach = detailDto.cryptoNetworkName.localizedCaseInsensitiveContains(searchText)
                    return isNetworkMach || isNameMach
                })
                createCryptoArray(withData: newData)
            }else
            {
                createCryptoArray(withData: cryptosData)
            }
            searching = searchText.count == 0 ? false : true
            tableView.reloadData()
        }else
        {
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
}
extension SelectViewController {
    // 索引设置
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if currentSelectMode == .selectCrypto
        {
            return []
        }else
        {
            var indexArray:[String] = []
            for (key , _) in sortedNameDataArray {
                indexArray.append(key)
            }
            return indexArray
        }
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        print(title , index)
        tableView.scrollToRow(at: IndexPath(item: 0, section: index), at: .top, animated: true)
        return index
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentSelectMode == .selectCrypto
        {
            return 1
        }else
        {
            return sortedNameDataArray.count
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentSelectMode == .selectCrypto
        {
            return nil
        }else
        {
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
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentSelectMode == .selectCrypto
        {
            let selectedCrypto = sortedCryptosDataArray[indexPath.row]
            onSelectedCryptoClick.onNext(selectedCrypto)
            self.dismiss(animated: true)
        }else
        {
            let selectedCode = sortedCodeDataArray[indexPath.section].value[indexPath.row]
            onSelectedAreaCodeClick.onNext(selectedCode)
            self.dismiss(animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSelectMode == .selectCrypto
        {
            return sortedCryptosDataArray.count
        }else
        {
            return sortedNameDataArray[section].value.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentSelectMode == .selectCrypto
        {
            let cell = tableView.dequeueCell(type: SelectCryptoCell.self, indexPath: indexPath)
            cell.config(withData: sortedCryptosDataArray[indexPath.row])
            return cell
        }else
        {
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
   
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentSelectMode == .selectCrypto
        {
            return 67
        }else
        {
            return 46
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if currentSelectMode == .selectCrypto
        {
            return 0
        }else
        {
            return 18
        }
        
    }
}
