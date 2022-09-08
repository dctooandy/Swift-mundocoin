//
//  AddressBookService.swift
//  cryptoVerOne
//
//  Created by BBk on 9/8/22.
//

import Foundation
import Foundation
import RxCocoa
import RxSwift
import Alamofire

class AddressBookService {

    //Create Customer Address Book
    func createAddressBook(address : String , name : String , label : String) -> Single<AddressBookDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["currency"] = "USDT"
        parameters["chain"] = "TRON"
        parameters["address"] = address
        parameters["name"] = name
        parameters["label"] = label

        return Beans.requestServer.singleRequestPost(
            path: ApiService.customerCreateAddressBook.path,
            parameters: parameters,
            modify: false,
            resultType: AddressBookDto.self).map({
                return $0
            })
    }
    //Query Customer Address Book
    func queryAddressBooks() -> Single<AddressBookListDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["page"] = "0"
        parameters["size"] = "999"
        return Beans.requestServer.singleRequestGet(
            path: ApiService.customerQueryAddressBooks.path,
            parameters: parameters,
            modify: false,
            resultType: AddressBookListDto.self).map({
                return $0
            })
    }
    //Enable Customer Address Book White List
    func enableAddressBookWhiteList() -> Single<WalletAddressDto?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletAddress.path,
            parameters: parameters,
            modify: false,
            resultType: WalletAddressDto.self).map({
                return $0
            })
    }
    
    //Update Customer Address Book Status
    func updateAddressBookStatus(addressBook:String) -> Single<WalletAddressDto?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletAddress.path,
            parameters: parameters,
            modify: false,
            resultType: WalletAddressDto.self).map({
                return $0
            })
    }
    //Delete Customer Address Book
    func deleteAddressBookStatus(addressBook:String) -> Single<WalletAddressDto?>
    {
        let parameters: Parameters = [String: Any]()
        return Beans.requestServer.singleRequestGet(
            path: ApiService.walletAddress.path,
            parameters: parameters,
            modify: false,
            resultType: WalletAddressDto.self).map({
                return $0
            })
    }
}
