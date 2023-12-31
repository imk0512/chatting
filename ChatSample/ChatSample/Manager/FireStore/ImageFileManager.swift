//
//  ImageFileManager.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/28.
//

import Foundation
import FirebaseStorage
import UIKit

final class ImageFileManager {
  
  static let shared = ImageFileManager()
  private init() {}
 
  
  private let storage = Storage.storage().reference()
  
  private var imagesReference: StorageReference {
    storage.child("images")
  }
  
  private func userReference(userId: String) -> StorageReference {
    storage.child("users").child(userId)
  }
  
  private func massageReference(massageId: String) -> StorageReference {
    storage.child("massages").child(massageId)
  }
  
  func getUrlForImage(path: String) async throws -> URL {
   try await Storage.storage().reference(withPath: path).downloadURL()
  }
  
  func getData(userId:String, path: String) async throws -> Data {
//    try await userReference(userId: userId).child(path).data(maxSize: 100 * 1024 * 1024)
    
    try await storage.child(path).data(maxSize: 100 * 1024 * 1024)
  }
  
  func getImage(userId:String, path: String) async throws -> UIImage {
    let data = try await getData(userId:userId, path:path)
    
    guard let image = UIImage(data: data) else {
      throw URLError(.badServerResponse)
    }
    return image
  }

  
  func saveImage(data: Data, userId: String) async throws -> (path: String, name: String){
 
    let meta = StorageMetadata()
    meta.contentType = "image/jpeg"
    let path = "\(UUID().uuidString).jpeg"
    let returnedMetaData  = try await userReference(userId: userId).child(path).putDataAsync(data,metadata: meta)
    
    guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
      throw URLError(.badServerResponse)
    }
    
    return (returnedPath, returnedName)
      
  }
  
  func saveImage(image: UIImage, userId:String) async throws -> (path: String, name: String){
    guard let data = image.jpegData( compressionQuality: 1) else {
      throw URLError(.backgroundSessionWasDisconnected)
    }
    
    return try await saveImage(data: data,userId: userId)
  }
  
  func getMassageImageData(userId:String, path: String) async throws -> Data {
    
    try await storage.child(path).data(maxSize: 100 * 1024 * 1024)
  }
  
  func saveMassageImage(data: Data, massageId: String) async throws -> (path: String, name: String){
 
    let meta = StorageMetadata()
    meta.contentType = "image/jpeg"
    let path = "\(UUID().uuidString).jpeg"
    let returnedMetaData  = try await massageReference(massageId: massageId).child(path).putDataAsync(data,metadata: meta)
    
    guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
      throw URLError(.badServerResponse)
    }
    
    return (returnedPath, returnedName)
      
  }
  
  func saveMassageImage(image: UIImage, massageId:String) async throws -> (path: String, name: String){
    guard let data = image.jpegData( compressionQuality: 1) else {
      throw URLError(.backgroundSessionWasDisconnected)
    }
    
    return try await saveMassageImage(data: data,massageId: massageId)
  }
}
