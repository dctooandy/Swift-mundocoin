//
//  UserInfoDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//
import Foundation
import RxSwift
class UserInfoDto: Codable {
    static var share:UserInfoDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<UserInfoDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update(done: {})
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<UserInfoDto?>(value: nil)
    static func update(done: @escaping () -> Void) -> Observable<()>{
        let subject = PublishSubject<Void>()
//        Beans.userServer.fetchUserInfo().subscribeSuccess({ (userInfoDto) in
//            share = userInfoDto
//            share?.isNeedHeadOffNaviPopEvent = false
//            _ = LoadingViewController.dismiss()
//            done()
//            subject.onNext(())
//        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
    // Login才有
    let isrecord:Int?
    let user_type:Int?
    let fans_num:Int?
    let is_anchor:Int?
    let id:Int?
    var level:Int?                      // 用户等级
    let issuper:Int?                   // 是否被超管 yes 不允许切换放假
    let qqgroup:String?
    let avatar_thumb:String?
    let votes:Int?                   // 映票数
    let ishot:Int?
    let lotterytime:Int?
    let score:Int?
    let votestotal:Int?                 // 总映票数
    var coin:Int?                       // 钻石数
    let level_anchor:Int?               // 主播等级
    let sex:String?                        // 性别
    let user_email:String?
    let user_login:String?
    let create_time:String?
    let user_status:Int?                // 用户状态
    let user_url:String?
    let birthday:String?                // 生日
    let red_coin:Int?
    let source:String?
    let lotterysum:Int?
    let usertype:Int?
    let city:String?                    // 城市
    let avatar:String?
    let login_type:String?              // 登录类型
    let user_nicename:String?
    let mobile:String?
    let consumption:Int?                // 消费总额
    let province:String?                // 省份
    let iszombiep:Int?
    let sign:String?
    let isrecommend:Int?
    let goodnum:String?
    let signature:String?               // 签名
    let cashbacktime:Int?
    let iszombie:Int?
    let banana: Int?
    //2020/12/18 判斷是否要攔截pop事件
    var isNeedHeadOffNaviPopEvent: Bool?
    init(
        isrecord:Int = 0,
        user_type:Int = 0,
        fans_num:Int = 0,
        is_anchor:Int = 0,
        id:Int = 0,
        level:Int = 0,
        issuper:Int = 0,
        qqgroup:String = "",
        avatar_thumb:String = "",
        votes:Int = 0,
        ishot:Int = 0,
        lotterytime:Int = 0,
        score:Int = 0,
        votestotal:Int = 0,
        coin:Int = 0,
        level_anchor:Int = 0,
        sex:String = "",
        user_email:String = "",
        user_login:String = "",
        create_time:String = "",
        user_status:Int = 0,
        user_url:String = "",
        birthday:String = "",
        red_coin:Int = 0,
        source:String = "",
        lotterysum:Int = 0,
        usertype:Int = 0,
        city:String = "",
        avatar:String = "",
        login_type:String = "",
        user_nicename:String = "",
        mobile:String = "",
        consumption:Int = 0,
        province:String = "",
        iszombiep:Int = 0,
        sign:String = "",
        isrecommend:Int = 0,
        goodnum:String = "",
        signature:String = "",
        cashbacktime:Int = 0,
        iszombie:Int = 0,
        banana: Int = 0,
        isNeedHeadOffNaviPopEvent: Bool = false
    )
    {
        self.isrecord = isrecord
        self.user_type = user_type
        self.fans_num = fans_num
        self.is_anchor = is_anchor
        self.id = id
        self.level = level
        self.issuper = issuper
        self.qqgroup = qqgroup
        self.avatar_thumb = avatar_thumb
        self.votes = votes
        self.ishot = ishot
        self.lotterytime = lotterytime
        self.score = score
        self.votestotal = votestotal
        self.coin = coin
        self.level_anchor = level_anchor
        self.sex = sex
        self.user_email = user_email
        self.user_login = user_login
        self.create_time = create_time
        self.user_status = user_status
        self.user_url = user_url
        self.birthday = birthday
        self.red_coin = red_coin
        self.source = source
        self.lotterysum = lotterysum
        self.usertype = usertype
        self.city = city
        self.avatar = avatar
        self.login_type = login_type
        self.user_nicename = user_nicename
        self.mobile = mobile
        self.consumption = consumption
        self.province = province
        self.iszombiep = iszombiep
        self.sign = sign
        self.isrecommend = isrecommend
        self.goodnum = goodnum
        self.signature = signature
        self.cashbacktime = cashbacktime
        self.iszombie = iszombie
        self.banana = banana
        self.isNeedHeadOffNaviPopEvent = isNeedHeadOffNaviPopEvent
    }
   
    var toJsonString: String {
        do {
            let jsonData = try self.jsonData()
            //            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            //                  guard let dictionary = json as? [String : Any] else {
            //                    return [:]
            //                  }
            //            return dictionary as Dictionary
            // Use dictionary
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }
            return jsonString
            //                  // Print jsonString
            //                  print(jsonString)
        } catch  {
            
        }
        return ""
    }
  
}
