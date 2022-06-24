//
//  Constants.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation

struct ErrorCode {
    
    static let ACCOUNT_LOGIN_FAIL_THRICE_4009 = 4009
    static let ACCOUNT_SIGNUP_FAIL_THRICE_1107 = 1107
    static let PHONE_SIGNUP_LOGIN_FAIL_THRICE_1103 = 1103
    static let EMAIL_FORGOT_FAIL_1016 = 1016
    static let EMAIL_FORGOT_FAIL_1017 = 1017
    static let EMAIL_FORGOT_FAIL_1005 = 1005
    static let PROMOTION_CONFLICT = 3006
    static let BAD_REQUEST_EXCEPTION = 1350
    static let MAINTAIN_B_PLATFORM_EXCEPTION = 9100
    static let MAINTAIN_B_DW_EXCEPTION = 9200
    static let MAINTAIN_B_SPORT_EXCEPTION = 9300
}

class Constants {
    // Https JWT Key
    static let Tiger_SecretKey = "84j5dcduprz7"
    // bypass save jwt url
    static let saveJWTUrl = ["authentication","token"]
    
    // Slider Text
    static let Tiger_Text_SliderPlaceHolder = "拖动滑块完成验证"
    static let Tiger_Text_SliderDonePlaceHolder = "完成验证"
    
    //Side 表單選項
    static let Tiger_Text_Side_MainPage = "首页"
    static let Tiger_Text_Side_Login = "注册"
    static let Tiger_Text_Side_SignUp = "登录"
    
    static let Tiger_Text_Side_SaveMoney = "存款"
    static let Tiger_Text_Side_TransMoney = "转账"
    static let Tiger_Text_Side_CashOut = "提款"
    
    static let Tiger_Text_Side_InBoxMail = "站內信"
    static let Tiger_Text_Side_VIPInvite = "VIP招募"
    static let Tiger_Text_Side_Delegate = "代理合作"
    static let Tiger_Text_Side_More = "更多VIP线路"
    static let Tiger_Text_Side_APPDownload = "APP下载"
    static let Tiger_Text_Side_WebService = "在线客服"
    static let Tiger_Text_Side_Logout = "退出"
    
    static let Tiger_Text_Cell_LoginConfirm = "立即登录"
    static let Tiger_Text_Cell_SignupConfirm = "注册"
    static let Tiger_Text_Cell_ErrorSliderLocation = "拖动滑块完成验证"
    static let Tiger_Text_Cell_ErrorCheckMarkDefault = "请确认填入讯息"
    static let Tiger_Text_Cell_ErrorCheckMarkUncheck = "请同意《相关的条款》和《隐私权政策》"
    static let Tiger_Text_Cell_ErrorUserNameEmpty = "请输入用户名"
    static let Tiger_Text_Cell_ErrorUserNameNoCurrect = "请输入A-Z, a-z, 0-9、5~15字符"
    static let Tiger_Text_Cell_ErrorUserPhoneNoCurrect = "请输入正确的手机号"
    static let Tiger_Text_Cell_ErrorUserPhoneEmpty = "请输入手机号"
    static let Tiger_Text_Cell_ErrorUserEmailNoCurrect = "请输入正确的邮箱"
    static let Tiger_Text_Cell_ErrorUserPasswordNoCurrect = "请输入8~20字母和数字或下划线的组合、不含特殊符号"
    static let Tiger_Text_Cell_ErrorUserRecheckPWNoCurrect = "请输入密码"
    
    static let Tiger_ForgatPW_Cell_Setp1_InsertInfoDescription = "输入验证信息"
    static let Tiger_ForgatPW_Cell_Setp1_FieldPlaceholderPhone = "请输入手机号"
    static let Tiger_ForgatPW_Cell_Setp1_NextStep = "接收验证码"
    static let Tiger_ForgatPW_Cell_Setp2_ShowUserKeyinInfo = "已发送验证码至"
    static let Tiger_ForgatPW_Cell_Setp2_NextStep = "下一步"
    static let Tiger_ForgatPW_Cell_Step2_FireToMail = "电子邮箱"
    static let Tiger_ForgatPW_Cell_Step2_FireToPhone = "手机"
    static let Tiger_ForgatPW_Cell_Setp2_ShowVerifyString = "输入您收到的验证码"
    
    static let Tiger_ForgatPW_Cell_Setp3_SetupNewPW = "设定新密码"
    static let Tiger_ForgatPW_Cell_Setp3_FieldPlaceholderNewPW = "请输入新密码"
    static let Tiger_ForgatPW_Cell_Setp3_ConfirmFieldPlaceholderNewPW = "再次确认密码"
    static let Tiger_ForgatPW_Cell_Setp3_Supmit = "提交"
    static let Tiger_ForgatPW_Cell_Setp4_SuccessChangePW = "修改成功"
    static let Tiger_ForgatPW_Cell_Setp4_BackToMain = "回到首页"
    
    static let Tiger_ForgatPW_Cell_Step2_ErrorParameters = "参数错误"
    static let Tiger_ForgatPW_Cell_Stet2_FullVarifyError = "验证失败，请正确输入手机或邮箱及验证码"
    static let Tiger_ForgatPW_Cell_Stet3_NewPWEmptyChat = "请输入8~20字母和数字或下划线的组合、不含特殊符号"
    static let Tiger_ForgatPW_Cell_Stet3_PWNoCurrect = "请确认密码一致性"
    
    static let Tiger_ForgatPW_Cell_InsertError = "请确认填入讯息"
    static let Tiger_ForgatPW_Cell_InsertNewPasswordDescription = "填写验证资讯"
    static let Tiger_ForgatPW_Cell_ErrorUserEmailNoCurrect = "请输入正确的手机"
    static let Tiger_ForgatPW_Cell_ErrorUserRecheckPWNoCurrect = "请输入新密码"
    
    static let Tiger_Typeing_Not_Consistent = "两次输入不一致！"
    
    // Mark: Error
    static let Tiger_ToastError_WebPageUrlError = "无法开启网页"
    static let Tiger_ToastError_NetWorkError = "网路中断"
    // Mark: Message
    static let Tiger_ToastMessage_LogoutSuccess = "登出成功"
    static let Tiger_ToastMessage_LoginSuccess = "登入成功"
    static let Tiger_ToastMessage_SignupSuccess = "注册成功"
    
    // Mark: Delegate Account
    static let Tiger_Delegate_NumberHint = "请输入代理编号"
    static let Tiger_Delegate_NumberErrorHint = Tiger_Text_Cell_ErrorUserNameNoCurrect
    static let Tiger_Delegate_AccountHint = "请输入代理账号"
    static let Tiger_Delegate_AccountErrorHint = Tiger_Text_Cell_ErrorUserNameNoCurrect
    static let Tiger_Delegate_NameHint = "请输入代理名称"
    static let Tiger_Delegate_NameErroeHint = "请输入中文, 英文, 数字、合计30字符内"
    static let Tiger_Delegate_RealNameHint = "请输入姓名"
    static let Tiger_Delegate_RealNameErrorHint = "请输入真实姓名"
    static let Tiger_Delegate_MailHint =  "请输入邮箱"
    static let Tiger_Delegate_MailErrorHint = Tiger_Text_Cell_ErrorUserEmailNoCurrect
    
    //Mark Error Code
    static let Tiger_LoginErrorCode = "20028"
    
    static let BetLead_NotSetting = "未设定"
    static let BetLead_PleaseContactService = "请联系客服修改"
}

class NotifyConstant {
    static let betleadAccountVerifyUpdated = Notification.Name("betleadAccountVerifyUpdated")
    static let betleadMemberUpdated = Notification.Name("betleadMemberUpdated")
    static let betleadBankCardUpdated = Notification.Name("betleadBankCardUpdated")
    static let betleadGameGroupIdUpdated = Notification.Name("betleadGameGroupIdUpdated")
    static let betleadVCRelaodData = Notification.Name("betleadVCRelaodData")
    static let betleadWalletUpdated = Notification.Name("betleadWalletUpdated")
    static let betleadShowBlur = Notification.Name("betleadShowBlur")
    static let betleadCleanBlur = Notification.Name("betleadCleanBlur")
    static let betleadShowGiveupBtn = Notification.Name("betleadShowGiveupBtn")
}
struct ApiCode {
    
    static let kDefaultSuccessCode = 200
}
