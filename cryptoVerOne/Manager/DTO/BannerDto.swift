//
//  BannerDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation

class BannerDto:Codable {
    let id:Int
    let bannerGroupId:ValueIntDto
    let bannerTitle:String
    let bannerDevice:ValueStringDto?
    let bannerImagePc:String
    let bannerImageMobile:String
    let bannerVideo:String?
    let bannerVideoBg:String?
    let bannerVideoImage:String?
    let bannerLinkPc:String?
    let bannerLinkMobile:String?
    let bannerTimeStart:String
    let bannerTimeEnd:String
    let bannerSort:Int
    let bannerStatus:ValueIntDto
    let bannerCreatedUser:ValueIntDto?
    let bannerUpdatedUser:ValueIntDto?
    let bannerCreatedAt:String
    let bannerUpdatedAt:String
    // 20190902 依據server 新增
    let bannerVideoPc:String?
    let bannerVideoPc2:String?
    let bannerVideoMobile:String?
    let bannerVideoMobile2:String?
    let bannerVideoBgPc:String?
    let bannerVideoBgMobile:String?
    //    20190802 test 是Int, Stage是String
    let bannerLinkMethod:ValueIntDto
    let bannerType:Int
    //    let bannerLinkMethod:ValueStringDto
    //    let bannerType:String
}
